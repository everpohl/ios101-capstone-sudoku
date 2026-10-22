//
//  SudokuGenerationService.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/20/26.
//

import Foundation

class SudokuGenerationService {
    static func generateBoard(size: Int, difficulty: Difficulty) -> SudokuGame {
        //Unimplemented function
    }
    
    func checkGrid(grid: [[Int?]]) -> Bool {
        for i in 0...grid.count {
            for j in 0...grid[i].count {
                if grid[i][j] == nil { return false }
            }
        }
        return true
    }
    var counter = 0
    func solveGrid(grid: inout [[Int?]]) {
        for i in 0...81 {
            let row = i/9
            let col = i%9
            for j in 1...10 {
                if !grid[row].contains(j) {
                    if !grid.contains(where: { $0[col] == j }) {
                        var lowerRow: Int
                        var upperRow: Int
                        var lowerCol: Int
                        var upperCol: Int
                        if row<3 {
                            lowerRow = 0; upperRow = 3
                        } else if row<6 {
                            lowerRow = 3; upperRow = 6
                        } else {
                            lowerRow = 6; upperRow = 9
                        }
                        if col<3 {
                            lowerCol = 0; upperCol = 3
                        } else if col<6 {
                            lowerCol = 3; upperCol = 6
                        } else {
                            lowerCol = 6; upperCol = 9
                        }
                        let square = (lowerRow..<upperRow).map { Array(grid[$0][lowerCol..<upperCol]) }
                        if !(square[0] + square[1] + square[2]).contains(j) {
                            grid[row][col] = j
                            if checkGrid(grid: grid) {
                                counter += 1
                                break
                            } else {
                                if solveGrid(grid) {
                                    return true
                                }
                            }
                        }
                    }
                }
                break
            }
            grid[row][col]=0
        }
    }
}
