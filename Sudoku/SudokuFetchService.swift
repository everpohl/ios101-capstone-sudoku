//
//  SudokuFetchService.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/15/26.
//

import Foundation

class SudokuFetchService {
    enum Difficulty: String {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
    }
    static func fetchSudoku(difficulty: Difficulty, width: Int, height: Int, completion: ((SudokuAPIResponse) -> Void)? = nil) {
        let apiKey = "***REMOVED***"
        let parameters = "difficulty=\(difficulty)&width=\(width)&height=\(height)"
        let url = URL(string: "https://api.api-ninjas.com/v1/sudokugenerate?\(parameters)")!
        
        //claude's code to pass the api key into the header
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                assertionFailure("Error: \(error!.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                assertionFailure("Invalid Response")
                return
            }
            guard let data = data, httpResponse.statusCode == 200 else {
                assertionFailure("Invalid response status code: \(httpResponse.statusCode)")
                return
            }
            let response = try! JSONDecoder().decode(SudokuAPIResponse.self, from: data)
            DispatchQueue.main.async {
                completion?(response.sudokuBoard) //call the completion colosure and pass in the forecast data model
            }
        }
        task.resume()
    }
}
