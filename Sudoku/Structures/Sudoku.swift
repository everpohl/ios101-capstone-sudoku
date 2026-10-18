//
//  Sudoku.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/15/26.
//

nonisolated struct SudokuAPIResponse: Codable {
    let puzzle: [[Int?]]
    let solution: [[Int]]
    
    private enum CodingKeys: String, CodingKey {
        case puzzle = "puzzle"
        case solution = "solution"
    }
}

struct SudokuGame {
    let solution: [[Int]]
    let initial: [[Bool]]
    private(set) var board: [[Int?]]
    private(set) var mistakes = 0
    
    init(from response: SudokuAPIResponse) {
        solution = response.solution
        board = response.puzzle
        initial = response.puzzle.map {row in row.map { $0 != nil} }
    }
    
    mutating func play(_ value: Int, row: Int, col: Int) -> Bool {
        if (initial[row][col] || isSolved) {
            return false
        }
        board[row][col] = value
        if (solution[row][col] != value) {
            mistakes += 1
        }
        return true
    }
    
    var isSolved: Bool {
        return solution == board
    }
}
