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
    //the rotation (landscape/portrait) the buttons were last arranged for
    private var currentAxis: NSLayoutConstraint.Axis?
    private var pause = false
    private var tickTask: Task<Void, Never>?
    
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
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.updateSubtitle()
                try? await Task.sleep(for: .seconds(1))
            }
        }
        boardView.delegate = self
        for i in 1...10 {
            if game.numberFilled(value: i) {
                buttonCollection.first(where: {$0.tag == i})?.isEnabled = false
            }
        }
        renderBoard()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //Pick the stack axis from the space actually available, rather than size classes.
        //This runs whenever the view's bounds change: rotation, iPhone Duo fold/unfold, split view, or window resizing.
        let available = view.safeAreaLayoutGuide.layoutFrame.size
        let axis: NSLayoutConstraint.Axis = available.width > available.height ? .horizontal : .vertical
        //only rearrange on rotation
        guard axis != currentAxis else { return }
        currentAxis = axis
        mainStackView.axis = axis
        //side by side, center the buttons vertically instead of stretching them to full height,
        //since the number buttons are capped at a max size in the storyboard
        mainStackView.alignment = axis == .horizontal ? .center : .fill
        arrangeButtons(for: axis)
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
        //Ensure that the theme is updated, just in case the user has changed the theme.
        for button in buttonCollection {
            button.configuration?.baseBackgroundColor = Theme.current.color
        }
        for i in 1...10 {
            if game.numberFilled(value: i) {
                buttonCollection.first(where: {$0.tag == i})?.isEnabled = false
            }
        }
        renderBoard()
        if (!pause) {
            game.timer.start()
        }
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.updateSubtitle()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tickTask?.cancel()
        tickTask = nil
        game.timer.pause()
        GameStore.shared.update(game)
    }
    
    //MARK: - Gameplay Methods
    func playerEntered(_ value: Int, atRow row: Int, atCol col: Int) {
        if (pencilMode) {} else {
            if game.play(value, row: row, col: col) {
                GameStore.shared.update(game)
                renderBoard()
                if game.numberFilled(value: value) {
                    buttonCollection.first(where: {$0.tag == value})?.isEnabled = false
                }
            } else {
                //indicate cell can't be modified
                boardView.cell(row: row, column: col).shake()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
    
    func boardView(_ boardView: BoardView, didSelectRow row: Int, column: Int) {
        if (selected ?? (9, 9) == (row, column)) {
            selected = nil
            //If tapped cell is already selected, deselect it
        } else {
            selected = (row, column)
            //If a cell isn't selected or is not the currently
            //selected cell, select the tapped cell
        }
        renderBoard()
    }
    
    //MARK: -Rendering Methods
    
    //Updates the top subtitle, which displays difficulty and the timer. if the timer is disabled, the timer will not render.
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
        //update each cell based on the game.board param, including marking invlaid cells with red. This method is at the conclusion of every method which involves modifying the board.
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
                    isGiven: game.initial[r][c],
                    highlight: highlight,
                    isConflict: conflicts.contains(Position(row: r, col: c))
                )
            }
        }
    }
    
    //MARK: - Button Methods
    
    //called whenever 1-9 buttons are pressed
    @IBAction func pressedNumberButton(_ sender: UIButton) {
        guard let s = selected else { return }
        playerEntered(sender.tag, atRow: s.row, atCol: s.col)
        renderBoard()
    }
    
    //called whenever pencil button is selected. updates the button appearance and pencilMode
    @IBAction func pencilToggle(_ sender: UIButton) {
        if (pencilMode) {
            toggleOn(button: sender)
        } else {
            toggleOff(button: sender)
        }
        pencilMode = !pencilMode
    }
    
    /* Undo/Redo is handled somewhere else. (i forgot where)?
    @IBAction func undoButton(_ sender: UIButton) {
    }
    @IBAction func redoButton(_ sender: UIButton) {
    }
    */
    
    @IBAction func eraserButton(_ sender: UIButton) {
        guard let s = selected else { return }
        if game.board[s.row][s.col] != nil, let removed = game.erase(row: s.row, col: s.col) {
            GameStore.shared.update(game)
            // the erased number may no longer be fully placed, so re-enable its button in case it was deleted.
            buttonCollection.first(where: {$0.tag == removed})?.isEnabled = true
        } else if game.initial[s.row][s.col] {
            boardView.cell(row: s.row, column: s.col).shake()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        renderBoard()
    }
    
    //Pauses game if pause button is pressed. Currently only pauses clock,
    @IBOutlet var pauseBar: UIBarButtonItem!
    @IBAction func pauseButton(_ sender: UIBarButtonItem) {
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
    
    //Resets the board. only handles the dialogue box here, the reset is processed in the game structure
    @IBAction func pressedReset(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to restart to the original board layout?", message: "This action cannot be undone", preferredStyle: .alert)
        let reset = UIAlertAction(title: "Restart", style: .destructive) { [unowned self] _ in
            game.restart()
            renderBoard()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(reset)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    //MARK: - Horizontal/Vertical layout handling
    
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
}
