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
    
    var game: SudokuGame! {
        didSet { GameStore.shared.update(game)}
    }
    private var selected: (row: Int, col: Int)?
    private var pencilMode = false
    
    //MARK: - UI View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //format number buttons and undo/redo/eraser
        for button in buttonCollection {
            button.layer.cornerRadius = button.frame.width/2
            var config = UIButton.Configuration.prominentGlass()
            config.attributedTitle = button.configuration?.attributedTitle
            config.baseForegroundColor = .white//.systemBackground
            config.baseBackgroundColor = Theme.current.color
            config.imagePadding = 7
            config.titlePadding = 7
            config.image = button.configuration?.image
            button.configuration = config
        }
        
        //format pencil button
        toggleOff(button: pencilButton)
        toggleOff(button: undoButton)
        toggleOff(button: eraseButton)
        
        //format navigation bar
        navigationItem.title = "Sudoku"
        navigationItem.style = .editor
        let difficulty = game.difficulty.rawValue.capitalized
        navigationItem.subtitle = "\(difficulty) - 13:65"
        boardView.delegate = self
        for i in 1...10 {
            if game.numberFilled(value: i) {
                buttonCollection.first(where: {$0.tag == i})?.isEnabled = false
            }
        }
        renderBoard()
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
        config.baseForegroundColor = .white//.systemBackground
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
                print("\(i) is filled")
                buttonCollection.first(where: {$0.tag == i})?.isEnabled = false
            }
        }
        renderBoard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GameStore.shared.update(game)
    }
    
    //MARK: - Gameplay Methods
    func playerEntered(_ value: Int, atRow row: Int, atCol col: Int) {
        if game.play(value, row: row, col: col) {
            GameStore.shared.update(game)
            renderBoard()
            if game.numberFilled(value: value) {
                buttonCollection.first(where: {$0.tag == value})?.isEnabled = false
            }
        } else {
            //indicate cell can't be modified
            boardView.cell(row: row, column: col).shake()
            UINotificationFeedbackGenerator().notificationOccurred(.error) // optional haptic
        }
    }
    
    func boardView(_ boardView: BoardView, didSelectRow row: Int, column: Int) {
        if (selected ?? (9, 9) == (row, column)) {
            print("double tap")
            selected = nil
        } else {
            selected = (row, column)
        }
        renderBoard()
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
                    } else if value != nil && value == selectedValue {
                        highlight = .sameNumber
                    } else if r == s.row || c == s.col || (r / 3 == s.row / 3 && c / 3 == s.col / 3) {
                        highlight = .related
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
    
    //later: add check that pencil mode isn't turned on, then add process for placing pencil values
    @IBAction func pressedNumberButton(_ sender: UIButton) {
        guard let s = selected else { return }
        playerEntered(sender.tag, atRow: s.row, atCol: s.col)
        renderBoard()
    }
    @IBAction func pencilToggle(_ sender: UIButton) {
        if (pencilMode) {
            toggleOn(button: sender)
        } else {
            toggleOff(button: sender)
        }
        pencilMode = !pencilMode
    }
    @IBAction func undoButton(_ sender: UIButton) {
    }
    @IBAction func redoButton(_ sender: UIButton) {
    }
    @IBAction func eraserButton(_ sender: UIButton) {
    }
    @IBAction func pauseButton(_ sender: UIBarButtonItem) {
    }
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
    }
}
