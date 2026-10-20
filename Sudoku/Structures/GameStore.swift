//
//  GameStore.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/19/26.
//

import Foundation

final class GameStore {
    static let shared = GameStore()

    private(set) var games: [SudokuGame] = []
    private let fileURL = URL.documentsDirectory.appendingPathComponent("games.json")

    private init() { load() }

    var activeGames: [SudokuGame] {
        games//.filter { !$0.isSolved }
             .sorted { $0.lastPlayed > $1.lastPlayed }
    }

    func add(_ game: SudokuGame) {
        games.append(game)
        save()
    }

    func update(_ game: SudokuGame) {
        guard let i = games.firstIndex(where: { $0.id == game.id }) else { return }
        games[i] = game
        save()
    }

    func delete(id: UUID) {
        games.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        games = (try? JSONDecoder().decode([SudokuGame].self, from: data)) ?? []
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(games)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save games: \(error)")
        }
    }
}
