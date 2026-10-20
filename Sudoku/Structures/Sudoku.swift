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
    let notes: [[[Int]]]
    var difficulty: Difficulty
    let size: Int
    private(set) var board: [[Int?]]
    private(set) var mistakes = 0
    var lastPlayed: Date
    let timer: GameTimer
    
    init(puzzle: [[Int?]], solution: [[Int]], difficulty: Difficulty, size: Int) {
        self.id = UUID()
        self.difficulty = difficulty
        self.solution = solution
        self.board = puzzle
        initial = puzzle.map {row in row.map { $0 != nil} }
        self.lastPlayed = Date()
        self.size = size
        self.notes = []
        self.timer = GameTimer()
    }
    
    init(from response: SudokuAPIResponse, difficulty: Difficulty, size: Int) {
        self.id = UUID()
        self.difficulty = difficulty
        solution = response.solution
        board = response.puzzle
        initial = response.puzzle.map {row in row.map { $0 != nil} }
        self.lastPlayed = Date()
        self.size = size
        self.notes = []
        self.timer = GameTimer()
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
    
    mutating func note(_ value: Int, row: Int, col: Int) {
        
    }
    
    // Clears a player-entered value. Returns the removed value, or nil if the cell can't be modified.
    mutating func erase(row: Int, col: Int) -> Int? {
        if (initial[row][col] || isSolved) {
            return nil
        }
        let removed = board[row][col]
        board[row][col] = nil
        lastPlayed = Date()
        return removed
    }

    // Resets the game back to it's original state, as well as clearing the timer and mistakes.
    mutating func restart() {
        mistakes = 0
        for r in board.indices {
            for c in board[r].indices where !initial[r][c] {
                board[r][c] = nil
            }
        }
        timer.reset()
    }
    
    var isSolved: Bool {
        return solution == board
    }
    
    func numberFilled(value: Int) -> Bool {
        var count = 0
        for r in board.indices {
            for c in board[r].indices where board[r][c] == value {
                count+=1
            }
        }
        return count == size*size
    }
    
    func conflictingCells() -> Set<Position> {
        var conflicts = Set<Position>()

        // Flags every cell in the group whose value appears more than once.
        func check(_ group: [Position]) {
            var seen: [Int: [Position]] = [:]
            for pos in group {
                if let v = board[pos.row][pos.col] {
                    seen[v, default: []].append(pos)
                }
            }
            for positions in seen.values where positions.count > 1 {
                conflicts.formUnion(positions)
            }
        }

        for i in 0..<9 {
            // Row i
            check((0..<9).map { Position(row: i, col: $0) })
            // Column i
            check((0..<9).map { Position(row: $0, col: i) })
            // Box i
            let r0 = (i / 3) * 3, c0 = (i % 3) * 3
            check((0..<9).map { Position(row: r0 + $0 / 3, col: c0 + $0 % 3) })
        }
        return conflicts
    }
}

struct Position: Hashable, Codable {
    let row: Int
    let col: Int

    var box: Int { (row / 3) * 3 + col / 3 }  // 0–8, handy for box checks

    func isRelated(to other: Position) -> Bool {
        row == other.row || col == other.col || box == other.box
    }
}
