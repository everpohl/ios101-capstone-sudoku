//
//  Secrets.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import Foundation

enum Secrets {
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "APIKey") as? String,
              !key.isEmpty else {
            fatalError("APIKey missing. Did you create Secrets.xcconfig?")
        }
        return key
    }
}
