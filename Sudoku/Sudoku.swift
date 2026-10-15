//
//  Sudoku.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/15/26.
//

class SudokuAPIResponse:Decodable {
    
}

class Sudoku: Codable {
    let puzzle: [[Int]]
    let solution: [[Int]]
    
    private enum codingKeys: String, CodingKey {
        case puzzle = "puzzle"
        case solution = "solution"
    }
}
