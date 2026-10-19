//
//  Sudoku.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/15/26.
//

import Foundation

nonisolated struct SudokuAPIResponse: Codable {
    let puzzle: [[Int?]]
    let solution: [[Int]]
    
    private enum CodingKeys: String, CodingKey {
        case puzzle = "puzzle"
        case solution = "solution"
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy, medium, hard
}

struct SudokuGame: Codable, Identifiable {
    let id : UUID
    let solution: [[Int]]
    let initial: [[Bool]]
    var difficulty: Difficulty
    private(set) var board: [[Int?]]
    private(set) var mistakes = 0
    var lastPlayed: Date
    
    init(from response: SudokuAPIResponse) {
        self.id = UUID()
        self.difficulty = .medium
        solution = response.solution
        board = response.puzzle
        initial = response.puzzle.map {row in row.map { $0 != nil} }
        self.lastPlayed = Date()
    }
    
    mutating func play(_ value: Int, row: Int, col: Int) -> Bool {
        if (initial[row][col] || isSolved) {
            return false
        }
        board[row][col] = value
        if (solution[row][col] != value) {
            mistakes += 1
        }
        lastPlayed = Date()
        return true
    }
    
    var isSolved: Bool {
        return solution == board
    }
}
