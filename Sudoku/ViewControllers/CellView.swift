//
//  CellView.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/19/26.
//

import UIKit

enum CellHighlight { case none, related, sameNumber, selected }

final class CellView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: Int?, isGiven: Bool, highlight: CellHighlight, isConflict: Bool) {
        label.text = value.map(String.init) ?? ""
        label.textColor = isConflict ? .systemRed : (isGiven ? .label : .systemBlue)
        switch highlight {
        case .none:       backgroundColor = .systemBackground
        case .related:    backgroundColor = .secondarySystemFill
        case .sameNumber: backgroundColor = .systemBlue.withAlphaComponent(0.25)
        case .selected:   backgroundColor = .systemBlue.withAlphaComponent(0.4)
        }
    }
}
