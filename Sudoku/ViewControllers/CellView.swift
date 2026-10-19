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
    private let tintView = UIView()

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
        backgroundColor = .systemBackground
        tintView.frame = bounds
        tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tintView.isUserInteractionEnabled = false
        insertSubview(tintView, at: 0)   // sits behind the label
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: Int?, isGiven: Bool, highlight: CellHighlight, isConflict: Bool) {
        label.text = value.map(String.init) ?? ""
        label.textColor = isConflict ? .systemRed : (isGiven ? .label : .systemBlue)
        switch highlight {
        case .none:       tintView.backgroundColor = .systemBackground
        case .related:    tintView.backgroundColor = Theme.current.color.withAlphaComponent(0.2)
        case .sameNumber: tintView.backgroundColor = Theme.current.color.withAlphaComponent(0.2)
        case .selected:   tintView.backgroundColor = Theme.current.color.withAlphaComponent(0.4)
        }
    }
}
