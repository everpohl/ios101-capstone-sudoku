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
    private let directoryURL = URL.documentsDirectory.appendingPathComponent("Games", isDirectory: true)
    private let legacyFileURL = URL.documentsDirectory.appendingPathComponent("games.json")

    private init() {
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        } catch {
            print("Failed to create games directory: \(error)")
        }
        migrateLegacyFileIfNeeded()
        load()
    }

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
        save(game)
    }

    func update(_ game: SudokuGame) {
        guard let i = games.firstIndex(where: { $0.id == game.id }) else { return }
        games[i] = game
        save(game)
    }

    func delete(id: UUID) {
        games.removeAll { $0.id == id }
        do {
            try FileManager.default.removeItem(at: fileURL(for: id))
        } catch {
            print("Failed to delete game \(id): \(error)")
        }
    }

    private func fileURL(for id: UUID) -> URL {
        directoryURL.appendingPathComponent("\(id.uuidString).json")
    }

    private func load() {
        let urls: [URL]
        do {
            urls = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        } catch {
            print("Failed to list games directory: \(error)")
            return
        }
        for url in urls where url.pathExtension == "json" {
            do {
                let data = try Data(contentsOf: url)
                games.append(try JSONDecoder().decode(SudokuGame.self, from: data))
            } catch {
                // A bad file only affects this one game. Since the game never makes it into
                // `games`, nothing will save over its file, so the data stays on disk.
                print("Failed to load \(url.lastPathComponent): \(error)")
            }
        }
    }

    private func save(_ game: SudokuGame) {
        do {
            let data = try JSONEncoder().encode(game)
            try data.write(to: fileURL(for: game.id), options: .atomic)
        } catch {
            print("Failed to save game \(game.id): \(error)")
        }
    }

    // One-time move from the old format, where every game lived in a single games.json
    private func migrateLegacyFileIfNeeded() {
        guard FileManager.default.fileExists(atPath: legacyFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: legacyFileURL)
            let legacyGames = try JSONDecoder().decode([SudokuGame].self, from: data)
            legacyGames.forEach(save)
            // Rename rather than delete so the original data is kept. The timestamp avoids a name
            // collision; if the move failed, migration would re-run and overwrite newer saves.
            let timestamp = Int(Date().timeIntervalSince1970)
            let migratedURL = URL.documentsDirectory.appendingPathComponent("games-migrated-\(timestamp).json")
            try FileManager.default.moveItem(at: legacyFileURL, to: migratedURL)
        } catch {
            // Leave games.json in place so it can be recovered
            print("Failed to migrate legacy games file: \(error)")
        }
    }
}
