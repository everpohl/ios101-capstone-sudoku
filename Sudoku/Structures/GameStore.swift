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
        games.filter { !$0.isSolved }
             .sorted { $0.lastPlayed > $1.lastPlayed }
    }
    
    var finishedGames: [SudokuGame] {
        games.filter { $0.isSolved }
             .sorted { ($0.timer.elapsedTime, $0.mistakes) < ($1.timer.elapsedTime, $1.mistakes) }
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
        do {
            games = try JSONDecoder().decode([SudokuGame].self, from: data)
        } catch {
            // Keep the unreadable file so its data isn't lost when the next save overwrites it
            print("Failed to load games: \(error)")
            let timestamp = Int(Date().timeIntervalSince1970)
            let backupURL = URL.documentsDirectory.appendingPathComponent("games-backup-\(timestamp).json")
            try? FileManager.default.copyItem(at: fileURL, to: backupURL)
        }
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
