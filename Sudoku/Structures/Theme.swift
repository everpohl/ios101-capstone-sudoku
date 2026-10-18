//
//  theme.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

enum Theme: String, CaseIterable {
    case blue, purple, pink, red, orange, yellow, green

    var color: UIColor {
        switch self {
        case .blue:   .systemBlue
        case .purple: .systemPurple
        case .pink:   .systemPink
        case .red:    .systemRed
        case .orange: .systemOrange
        case .yellow: .systemYellow
        case .green:  .systemGreen
        }
    }

    private static let key = "theme"

    static var current: Theme {
        get {
            UserDefaults.standard.string(forKey: key).flatMap(Theme.init(rawValue:)) ?? .blue
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
