//
//  SudokuViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

class SudokuViewController: UIViewController, BoardViewDelegate {

    @IBOutlet var boardView: BoardView!
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet weak var pencilButton: UIButton!
    
    var game: SudokuGame! {
        didSet { GameStore.shared.update(game)}
    }
    private var selected: (row: Int, col: Int)?
    
    //MARK: - UI View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //format number buttons and undo/redo/eraser
        for button in buttonCollection {
            button.layer.cornerRadius = button.frame.width/2
            var config = UIButton.Configuration.prominentGlass()
            config.attributedTitle = button.configuration?.attributedTitle
            config.baseForegroundColor = button.tintColor
            config.baseBackgroundColor = Theme.current.color
            config.imagePadding = 7
            config.titlePadding = 7
            config.image = button.configuration?.image
            button.configuration = config
        }
        
        //format pencil button
        var config = UIButton.Configuration.prominentClearGlass()
//        config.baseForegroundColor = Theme.current.color
        config.baseBackgroundColor = Theme.current.color
        config.image = pencilButton.configuration?.image
        pencilButton.configuration = config
        
        //format navigation bar
        navigationItem.title = "Sudoku"
        navigationItem.style = .editor
        let difficulty = game.difficulty.rawValue.capitalized
        navigationItem.subtitle = "\(difficulty) - 13:65"
        boardView.delegate = self
        renderBoard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Ensure that the theme is updated, just in case the user has changed the theme.
        for button in buttonCollection {
            button.configuration?.baseBackgroundColor = Theme.current.color
        }
        pencilButton.configuration?.image?.withTintColor(Theme.current.color) //= Theme.current.color
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
        } else {
            //indicate cell can't be modified
            
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
