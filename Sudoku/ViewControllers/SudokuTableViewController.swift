//
//  SudokuTableViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

class SudokuTableViewController: UITableViewController {
    @IBOutlet var newGame: UIBarButtonItem!
    private var games: [SudokuGame] = []
    private var isCreatingGame = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        newGame.menu = UIMenu(title: "New Game", children: Difficulty.allCases.map { difficulty in
            UIAction(title: difficulty.rawValue.capitalized) { [weak self] _ in
                self?.startNewGame(difficulty)
            }
        })

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
        games = GameStore.shared.activeGames
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return games.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let game = games[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = game.difficulty.rawValue.capitalized
//        let filled = game.board.filter { $0 != 0 }.count
//        config.secondaryText = "\(filled)/81 filled · \(game.lastPlayed.formatted(.relative(presentation: .named)))"
        cell.contentConfiguration = config
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        GameStore.shared.delete(id: games[indexPath.row].id)
        games.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: Creating boards methods
    private func startNewGame(_ difficulty: Difficulty) {
        guard !isCreatingGame else { return }
        isCreatingGame = true

        let addButton = navigationItem.rightBarButtonItem
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)

        SudokuFetchService.fetchSudoku(difficulty: difficulty, width: 3, height: 3) { [weak self] result in
            guard let self else { return }
            self.isCreatingGame = false
            self.navigationItem.rightBarButtonItem = addButton

            switch result {
            case .success(let response):
                let game = SudokuGame(from: response, difficulty: difficulty)
                GameStore.shared.add(game)
                self.performSegue(withIdentifier: "showGame", sender: game)
            case .failure(let error):
                self.showError(error) { [weak self] in self?.startNewGame(difficulty) }
            }
        }
    }
    
    private func showError(_ error: Error, retry: @escaping () -> Void) {
            let alert = UIAlertController(title: "Couldn't create a puzzle",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in retry() })
            present(alert, animated: true)
        }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard segue.identifier == "showGame",
                      let gameVC = segue.destination as? SudokuViewController,
                      let indexPath = tableView.indexPathForSelectedRow else { return }
                gameVC.game = games[indexPath.row]
    }
}
