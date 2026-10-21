//
//  LeaderboardTableViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/20/26.
//

import UIKit

class LeaderboardTableViewController: UITableViewController {
    
    private var filter: Difficulty?
    private var scores: [SudokuGame] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadScores()
    }
    
    private func reloadScores() {
          scores = GameStore.shared.finishedGames.filter { filter == nil || $0.difficulty == filter }
          tableView.reloadData()
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadScores()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Replace with your condition for unselectable rows
        return nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let game = scores[indexPath.row]
        let difficulty = game.difficulty.rawValue.capitalized
        let time = game.timer.elapsedTime.formatted(.time(pattern:.minuteSecond))
        let date = game.lastPlayed.formatted(date: .numeric, time: .omitted) //.relative(presentation: .named)
        let mistakes = game.mistakes
        config.text = "\(difficulty) Puzzle on \(date)\nFinish Time: \(time) - Mistakes: \(mistakes)"
        cell.contentConfiguration = config
        return cell
    }

    @IBAction func filterDifficulty(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filter = nil
        case 1:
            filter = .easy
        case 2:
            filter = .medium
        case 3:
            filter = .hard
        default:
            print("fuck you")
        }
    }
}
