//
//  SudokuGenerationService.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/20/26.
//

import Foundation

class SudokuGenerationService {
    static func generateBoard(size: Int, difficulty: Difficulty) -> SudokuGame {
        let generator = SudokuGenerationService()
        var remove: Int
        switch difficulty {
        case .easy: remove = 24
        case .medium: remove = 38
        case .hard: remove = 57
        //default: remove = 0
        }
        var grid = [[Int?]](repeating: [Int?](repeating: nil, count: 9), count: 9)
        _ = generator.fillGrid(grid: &grid)
        let solution = grid.map { $0.compactMap { $0 } }
        for position in (0..<81).shuffled() {
            if remove == 0 { break } //all expected cells are removed.
            let row = position / 9
            let col = position % 9
            let backup = grid[row][col]
            grid[row][col] = nil
            var copyGrid = grid
            generator.counter = 0
            _ = generator.solveGrid(grid: &copyGrid)
            if generator.counter == 1 {
                remove -= 1
            } else {
                grid[row][col] = backup
            }
        }
        return SudokuGame(puzzle: grid, solution: solution, difficulty: difficulty, size: size)
    }
    
    func checkGrid(grid: [[Int?]]) -> Bool {
        for i in 0..<grid.count {
            for j in 0..<grid[i].count {
                if grid[i][j] == nil { return false }
            }
        }
        return true
    }
    
    var counter = 0
    
    func solveGrid(grid: inout [[Int?]]) -> Bool {
        for i in 0..<81 {
            let row = i/9
            let col = i%9
            if grid[row][col] == nil {
                for j in 1...9 {
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
                                    if (counter > 1) {
                                        return true
                                    }
                                    break
                                } else {
                                    if solveGrid(grid: &grid) {
                                        return true
                                    }
                                }
                            }
                        }
                    }
                }
                grid[row][col]=nil
                break
            }
        }
        return false
    }
    
    var numberList=Array(1...9)
    
    func fillGrid(grid: inout [[Int?]]) -> Bool {
        for i in 0..<81 {
            let row = i/9
            let col = i%9
            if grid[row][col]==nil {
                numberList.shuffle()
                for number in numberList {
                    if !grid[row].contains(number) {
                        if !grid.contains(where: { $0[col] == number }) {
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
                            if !(square[0] + square[1] + square[2]).contains(number) {
                                grid[row][col] = number
                                if checkGrid(grid: grid) {
                                    return true
                                } else {
                                    if fillGrid(grid: &grid) {
                                        return true
                                    }
                                }
                            }
                        }
                    }
                }
                grid[row][col] = nil
                break
            }
        }
        return false
    }
}
