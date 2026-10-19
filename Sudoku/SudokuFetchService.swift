//
//  SudokuFetchService.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/15/26.
//

import Foundation

enum SudokuFetchError: Error {
    case badStatus(Int)
    case noData
}

class SudokuFetchService {
    static func fetchSudoku(difficulty: Difficulty, width: Int, height: Int, completion: @escaping (Result<SudokuAPIResponse, Error>) -> Void) {
        let apiKey = Secrets.apiKey
        let parameters = "difficulty=\(difficulty.rawValue)&width=\(width)&height=\(height)"
        let url = URL(string: "https://api.api-ninjas.com/v1/sudokugenerate?\(parameters)")!
        
        //claude's code to pass the api key into the header
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result: Result<SudokuAPIResponse, Error>

            if let error {
                result = .failure(error)
            } else if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                result = .failure(SudokuFetchError.badStatus(http.statusCode))
            } else if let data {
                result = Result { try JSONDecoder().decode(SudokuAPIResponse.self, from: data) }
            } else {
                result = .failure(SudokuFetchError.noData)
            }

            DispatchQueue.main.async { completion(result) }
        }.resume()
    }
}
