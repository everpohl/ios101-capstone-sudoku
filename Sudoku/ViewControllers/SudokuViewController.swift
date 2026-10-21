//
//  SudokuViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

class SudokuViewController: UIViewController, BoardViewDelegate {

    @IBOutlet var undoButton: UIButton!
    @IBOutlet var redoButton: UIButton!
    @IBOutlet var eraseButton: UIButton!
    @IBOutlet var boardView: BoardView!
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var buttonsStackView: UIStackView!
    
    var game: SudokuGame! {
        didSet { GameStore.shared.update(game)}
    }
    private var selected: (row: Int, col: Int)?
    private var pencilMode = false
    //the axis the buttons were last arranged for; nil until the first layout pass
    private var currentAxis: NSLayoutConstraint.Axis?
    private var pause = false
    private var tickTask: Task<Void, Never>?
    private let gameUndoManager = UndoManager()
    override var undoManager: UndoManager? { gameUndoManager }
    
    //MARK: - UI View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //format number buttons and undo/redo/eraser
        for button in buttonCollection {
            button.layer.cornerRadius = button.frame.width/2
            var config = UIButton.Configuration.prominentGlass()
            config.attributedTitle = button.configuration?.attributedTitle
            config.baseForegroundColor = .white
            config.baseBackgroundColor = Theme.current.color
            config.imagePadding = 7
            config.titlePadding = 7
            config.image = button.configuration?.image
            button.configuration = config
        }
        
        //format pencil button
        toggleOff(button: pencilButton)
        toggleOff(button: undoButton)
        toggleOff(button: redoButton)
        toggleOn(button: eraseButton)
        
        //keep the undo/erase rows tall enough to tap. 999 instead of required so a very narrow
        //window (e.g. a slim iPad split view) bends this rather than breaking the layout
        let tallButtons: [UIButton] = [undoButton, eraseButton]
        for button in tallButtons {
            let minHeight = button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            minHeight.priority = UILayoutPriority(999)
            minHeight.isActive = true
        }
        
        //format navigation bar
        navigationItem.title = "Sudoku"
        navigationItem.style = .editor
        boardView.delegate = self
        updateNumberButtons()
        renderBoard()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(appResumedFromBackground),
                    name: UIApplication.willEnterForegroundNotification,
                    object: nil
                )
        NotificationCenter.default.addObserver(self, selector: #selector(undoManagerDidChange), name: .NSUndoManagerDidUndoChange, object: undoManager)
        NotificationCenter.default.addObserver(self, selector: #selector(undoManagerDidChange), name: .NSUndoManagerDidRedoChange, object: undoManager)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //Pick the stack axis from the space actually available, rather than size classes.
        //This runs whenever the view's bounds change: rotation, iPhone Duo fold/unfold, split view, or window resizing.
        let available = view.safeAreaLayoutGuide.layoutFrame.size
        let axis: NSLayoutConstraint.Axis = available.width > available.height ? .horizontal : .vertical
        //only rearrange on change so we don't trigger extra layout passes
        guard axis != currentAxis else { return }
        currentAxis = axis
        mainStackView.axis = axis
        //side by side, center the buttons vertically instead of stretching them to full height,
        //since the number buttons are capped at a max size in the storyboard
        mainStackView.alignment = axis == .horizontal ? .center : .fill
        arrangeButtons(for: axis)
    }
    
    /// Rebuilds the button rows for the current layout.
    /// Side by side (.horizontal): a narrow 3-wide grid, so the board gets more width.
    /// Stacked (.vertical): wide 5-across rows, so the board gets more height.
    private func arrangeButtons(for axis: NSLayoutConstraint.Axis) {
        let numbers = buttonCollection.sorted { $0.tag < $1.tag }
        guard numbers.count == 9 else { return }
        
        let rows: [UIStackView]
        if axis == .horizontal {
            rows = [
                makeRow(Array(numbers[0..<3]), equalWidths: true),
                makeRow(Array(numbers[3..<6]), equalWidths: true),
                makeRow(Array(numbers[6..<9]), equalWidths: true),
                makeRow([undoButton, redoButton]),
                makeRow([eraseButton, pencilButton])
            ]
        } else {
            rows = [
                makeRow(Array(numbers[0..<5]), equalWidths: true),
                makeRow(Array(numbers[5..<9]) + [pencilButton], equalWidths: true),
                makeRow([undoButton, redoButton, eraseButton], spacing: 13)
            ]
        }
        
        //the buttons have already moved into the new rows, so the old rows are empty.
        //removing them also drops any width constraints that referenced them
        for oldRow in buttonsStackView.arrangedSubviews {
            oldRow.removeFromSuperview()
        }
        for row in rows {
            buttonsStackView.addArrangedSubview(row)
        }
        //every row matches the first row's width, so the grid lines up.
        //button 1 is always in the first row and its size constraints set that width
        for row in rows.dropFirst() {
            row.widthAnchor.constraint(equalTo: rows[0].widthAnchor).isActive = true
        }
    }
    
    /// Makes a horizontal row. Adding a button to the row moves it out of its old row,
    /// keeping its outlets, actions, and size constraints.
    private func makeRow(_ buttons: [UIButton], equalWidths: Bool = false, spacing: CGFloat = 10) -> UIStackView {
        let row = UIStackView(arrangedSubviews: buttons)
        row.axis = .horizontal
        row.spacing = spacing
        //number buttons share the width equally; the undo/redo/erase rows size from each button's aspect ratio
        row.distribution = equalWidths ? .fillEqually : .fill
        return row
    }
    
    func toggleOff(button: UIButton) {
        var config = UIButton.Configuration.prominentClearGlass()
        config.attributedTitle = button.configuration?.attributedTitle
        config.baseForegroundColor = Theme.current.color
        config.image = button.configuration?.image
        config.imagePadding = 7
        config.titlePadding = 7
        button.configuration = config
    }
    
    func toggleOn(button: UIButton) {
        button.layer.cornerRadius = button.frame.width/2
        var config = UIButton.Configuration.prominentGlass()
        config.attributedTitle = button.configuration?.attributedTitle
        config.baseForegroundColor = .white
        config.baseBackgroundColor = Theme.current.color
        config.imagePadding = 7
        config.titlePadding = 7
        config.image = button.configuration?.image
        button.configuration = config
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Ensure that the theme is updated, just in case the user has changed the theme.
        for button in buttonCollection {
            button.configuration?.baseBackgroundColor = Theme.current.color
        }
        updateNumberButtons()
        updateUndoRedoButtons()
        renderBoard()
        if (!pause && !game.isSolved) {
            game.timer.start()
        }
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.updateSubtitle()
                try? await Task.sleep(for: .seconds(1))
                guard self != nil else { return }
            }
        }
        // Enable shake to undo
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tickTask?.cancel()
        tickTask = nil
        game.timer.pause()
        GameStore.shared.update(game)
    }
    
    @objc private func undoManagerDidChange(_ notification: Notification) {
        updateUndoRedoButtons()
    }

    @objc func appMovedToBackground() {
        game.timer.pause()
        GameStore.shared.update(game)
    }
    
    @objc func appResumedFromBackground() {
        if (!pause && !game.isSolved) {
            game.timer.start()
        }
    }
    
    // Must return true to participate in the responder chain actions
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - Gameplay Methods
    func playerEntered(_ value: Int, atRow row: Int, atCol col: Int) {
        if (game.isSolved) {
            return
        }
        if (pencilMode) {
            let oldNotes = game.notes[row][col]
            if game.note(value, row: row, col: col) {
                let move = SudokuGame.Move(row: row, col: col, oldValue: game.board[row][col], newValue: game.board[row][col], oldNotes: oldNotes, newNotes: game.notes[row][col])
                registerUndo(move, name: "noted \(value)")
                renderBoard()
            } else {
                boardView.cell(row: row, column: col).shake()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        } else {
            let oldValue = game.board[row][col]
            let oldNotes = game.notes[row][col]
            if game.play(value, row: row, col: col) {
                let move = SudokuGame.Move(row: row, col: col, oldValue: oldValue, newValue: game.board[row][col], oldNotes: oldNotes, newNotes: game.notes[row][col])
                registerUndo(move, name: "played \(value)")
                renderBoard()
                updateNumberButtons()
            } else {
                //indicate cell can't be modified
                boardView.cell(row: row, column: col).shake()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
        if game.isSolved {
            updateUndoRedoButtons()
            let alert = UIAlertController(title: "You solved the puzzle!", message: "Time: \(game.timer.elapsedTime.formatted(.time(pattern: .minuteSecond))) - Mistakes: \(game.mistakes)", preferredStyle: .alert)
            let reset = UIAlertAction(title: "Close Game", style: .default) { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            }
            let cancel = UIAlertAction(title: "View Board", style: .cancel)
            alert.addAction(reset)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    func boardView(_ boardView: BoardView, didSelectRow row: Int, column: Int) {
        if (selected ?? (9, 9) == (row, column)) {
            selected = nil
        } else {
            selected = (row, column)
        }
        renderBoard()
    }
    
    private func updateSubtitle() {
        let difficulty = game.difficulty.rawValue.capitalized
        let time = game.timer.elapsedTime.formatted(.time(pattern: .minuteSecond))
        if(UserDefaults.standard.bool(forKey: "timer")) {
            navigationItem.subtitle = "\(difficulty) Puzzle - \(time)"
        } else {
            navigationItem.subtitle = "\(difficulty) Puzzle"
        }
    }

    private func renderBoard() {
        //update each cell based on the game.board param, including marking invlaid cells with red
        let conflicts = game.conflictingCells()
        let selectedValue = selected.flatMap { game.board[$0.row][$0.col] }

        for r in 0..<9 {
            for c in 0..<9 {
                let value = game.board[r][c]
                var highlight = CellHighlight.none
                if let s = selected {
                    if r == s.row && c == s.col {
                        highlight = .selected
                    } else if UserDefaults.standard.bool(forKey: "peers") {
                        if value != nil && value == selectedValue {
                            highlight = .sameNumber
                        } else if r == s.row || c == s.col || (r / 3 == s.row / 3 && c / 3 == s.col / 3) {
                            highlight = .related
                        }
                    }
                }
                boardView.cell(row: r, column: c).configure(
                    value: value,
                    notes: game.notes[r][c],
                    isGiven: game.initial[r][c],
                    highlight: highlight,
                    isConflict: conflicts.contains(Position(row: r, col: c))
                )
            }
        }
    }
    
    @IBAction func pressedNumberButton(_ sender: UIButton) {
        guard let s = selected else { return }
        playerEntered(sender.tag, atRow: s.row, atCol: s.col)
        updateUndoRedoButtons()
        renderBoard()
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let digits = (1...9).map { n in
            UIKeyCommand(title: "Enter \(n)",
                         action: #selector(handleDigit(_:)),
                         input: "\(n)")
        }

        let arrows = [UIKeyCommand.inputUpArrow, UIKeyCommand.inputDownArrow,
                      UIKeyCommand.inputLeftArrow, UIKeyCommand.inputRightArrow]
            .map { UIKeyCommand(input: $0, modifierFlags: [], action: #selector(handleArrow(_:))) }

        // Without this, the system may use arrow keys for focus or scrolling first.
        arrows.forEach { $0.wantsPriorityOverSystemBehavior = true }

        /*
        let cut = UIKeyCommand(title: "Cut", action: #selector(cutCell),
                               input: "x", modifierFlags: .command)
        let copy = UIKeyCommand(title: "Copy", action: #selector(copyCell),
                                input: "c", modifierFlags: .command)
        let paste = UIKeyCommand(title: "Paste", action: #selector(pasteCell),
                                 input: "v", modifierFlags: .command)
        */
        return digits + arrows //+ [cut, copy, paste]
    }
    
    @objc func handleDigit(_ sender: UIKeyCommand) {
        guard let input = sender.input, let n = Int(input), let s = selected else { return }
//        guard let s = selected else { return }
        playerEntered(n, atRow: s.row, atCol: s.col)
        updateUndoRedoButtons()
        renderBoard()
    }

    @objc func handleArrow(_ sender: UIKeyCommand) {
        switch sender.input {
        case UIKeyCommand.inputUpArrow:
            guard var s = selected else { return }
            s.col -= 1
            selected = s
        case UIKeyCommand.inputDownArrow:
            guard var s = selected else { return }
            s.col += 1
            selected = s
        case UIKeyCommand.inputLeftArrow:
            guard var s = selected else { return }
            s.row -= 1
            selected = s
        case UIKeyCommand.inputRightArrow:
            guard var s = selected else { return }
            s.row += 1
            selected = s
        default: break
        }
    }
    
    @objc func undoMove() {
        if undoManager?.canUndo == true {
            undoManager?.undo()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    @objc func redoMove() {
        if undoManager?.canRedo == true {
            undoManager?.redo()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    @IBAction func pencilToggle(_ sender: UIButton) {
        if (!pencilMode) {
            toggleOn(button: sender)
        } else {
            toggleOff(button: sender)
        }
        pencilMode = !pencilMode
    }
    
    private func registerUndo(_ move: SudokuGame.Move, reversed: Bool = false, name: String) {
        undoManager?.registerUndo(withTarget: self) { targetSelf in
            // When an undo occurs, this closure runs.
            // Registering the reverse action here automatically builds the Redo step.
            targetSelf.registerUndo(move, reversed: !reversed, name: name)
            targetSelf.game.apply(move, reversed: !reversed)
            targetSelf.selected = (row: move.row, col: move.col)
            targetSelf.renderBoard()
            targetSelf.updateNumberButtons()
        }
        undoManager?.setActionName(name)
    }
    
    @IBAction func undoButton(_ sender: UIButton) {
        if undoManager?.canUndo == true {
            undoManager?.undo()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    @IBAction func redoButton(_ sender: UIButton) {
        if undoManager?.canRedo == true {
            undoManager?.redo()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    @IBAction func eraserButton(_ sender: UIButton) {
        guard let s = selected else { return }
        if game.board[s.row][s.col] != nil, let removed = game.erase(row: s.row, col: s.col) {
            // the erased number is no longer fully placed, so re-enable its button if the button was disabled
            buttonCollection.first(where: {$0.tag == removed})?.isEnabled = true
            let oldNotes = game.notes[s.row][s.col]
            let move = SudokuGame.Move(row: s.row, col: s.col, oldValue: removed, newValue: nil, oldNotes: oldNotes, newNotes: oldNotes)
            registerUndo(move, name: "erased \(removed)")
        } else if game.initial[s.row][s.col] {
            boardView.cell(row: s.row, column: s.col).shake()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        } else if (game.board[s.row][s.col] == nil && !game.notes.isEmpty) {
            if game.erase(row: s.row, col: s.col) != nil {
                print("uh erasing a spot with no value but that does have notes should return nil")
            }
        }
        renderBoard()
        updateNumberButtons()
        updateUndoRedoButtons()
    }
    
    @IBOutlet var pauseBar: UIBarButtonItem!
    @IBAction func pauseButton(_ sender: UIBarButtonItem) {
        guard !game.isSolved else { return }
        if !game.timer.isRunning {
            game.timer.start()
            pauseBar.image = UIImage(systemName: "pause.fill")
            pause = false
        } else {
            game.timer.pause()
            pauseBar.image = UIImage(systemName: "play.fill")
            pause = true
        }
        updateSubtitle()
    }
    
    @IBAction func pressedReset(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to restart to the original board layout?", message: "This action cannot be undone", preferredStyle: .alert)
        let reset = UIAlertAction(title: "Restart", style: .destructive) { [unowned self] _ in
            game.restart()
            renderBoard()
            if (!pause) { game.timer.start()}
            undoManager?.removeAllActions()
            updateUndoRedoButtons()
            updateNumberButtons()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(reset)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    func updateUndoRedoButtons() {
        if game.isSolved {
            //If the game is solved, there is no reason to undo/redo. Clearing all actions will both prevent any scenario where the user undoes or redoes their win, and will turn off both buttons since canUndo and canRedo will be false if this condition executes
            undoManager?.removeAllActions()
        }
        if undoManager?.canRedo == true {
            toggleOn(button: redoButton)
        } else {
            toggleOff(button: redoButton)
        }
        if undoManager?.canUndo == true {
            toggleOn(button: undoButton)
        } else {
            toggleOff(button: undoButton)
        }
    }
    
    func updateNumberButtons() {
        for button in buttonCollection {
            button.isEnabled = !game.numberFilled(value: button.tag)
        }
    }
}
