//
//  SudokuViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

class SudokuViewController: UIViewController {

    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet weak var pencilButton: UIButton!
    
    var game: SudokuGame! {
        didSet { GameStore.shared.update(game)}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //format number buttons and undo/redo/eraser
        for button in buttonCollection {
            button.layer.cornerRadius = button.frame.width/2
            var config = UIButton.Configuration.prominentGlass()
            config.attributedTitle = button.configuration?.attributedTitle
            config.baseForegroundColor = button.tintColor
            config.baseBackgroundColor = Theme.current.color
            config.image = button.configuration?.image
            button.configuration = config
        }
        
        //format pencil button
        var config = UIButton.Configuration.prominentClearGlass()
        config.baseForegroundColor = Theme.current.color
        config.image = pencilButton.configuration?.image
        pencilButton.configuration = config
        
        //format navigation bar
        navigationItem.title = "Sudoku"
        navigationItem.style = .editor
        navigationItem.subtitle = "normal - 13:65"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Ensure that the theme is updated, just in case the user has changed the theme.
        for button in buttonCollection {
            button.configuration?.baseBackgroundColor = Theme.current.color
        }
        pencilButton.configuration?.baseForegroundColor = Theme.current.color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GameStore.shared.update(game)
    }
    
    func playerEntered(_ value: Int, atRow row: Int, atCol col: Int) {
        if game.play(value, row: row, col: col) {
            GameStore.shared.update(game)
            renderBoard()
        } else {
            //indicate cell can't be modified
        }
    }
    
    private func renderBoard() {
        //update each cell based on the game.board param, including marking invlaid cells with red
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
