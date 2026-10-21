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
    private let noteView = UIStackView()
    private let noteLabels: [UILabel] = (0..<9).map { _ in UILabel() }
    private let tintView = UIView()
    private let noteSpacing:CGFloat = 3

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
        for noteLabel in noteLabels {
            noteLabel.textAlignment = .center
            noteLabel.font = .systemFont(ofSize: 10, weight: .medium)
            noteLabel.textColor = .secondaryLabel
        }
        for row in 0...2 {
            let rowStack = UIStackView(arrangedSubviews: Array(noteLabels[row * 3 ..< row * 3 + 3]))
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.alignment = .center
            rowStack.spacing = noteSpacing
            noteView.addArrangedSubview(rowStack)
        }
        noteView.axis = .vertical
        noteView.distribution = .fillEqually
//        noteView.alignment = .center
        noteView.spacing = noteSpacing
        noteView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(noteView)
        NSLayoutConstraint.activate([
            noteView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            noteView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            noteView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            noteView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2)
        ])
        backgroundColor = .systemBackground
        tintView.frame = bounds
        tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tintView.isUserInteractionEnabled = false
        insertSubview(tintView, at: 0)   // sits behind the label
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: Int?, notes: Set<Int>, isGiven: Bool, highlight: CellHighlight, isConflict: Bool) {
        label.text = value.map(String.init) ?? ""
        label.isHidden = value == nil
        noteView.isHidden = value != nil
        for (i, noteLabel) in noteLabels.enumerated() {
            noteLabel.text = notes.contains(i + 1) ? String(i + 1) : ""
        }
        label.textColor = isConflict ? UIColor(red: 1, green: 0, blue: 0, alpha: 1) : (isGiven ? .label : Theme.current.color)
        switch highlight {
        case .none:       tintView.backgroundColor = .systemBackground
        case .related:    tintView.backgroundColor = Theme.current.color.withAlphaComponent(0.2)
        case .sameNumber: tintView.backgroundColor = Theme.current.color.withAlphaComponent(0.2)
        case .selected:   tintView.backgroundColor = Theme.current.color.withAlphaComponent(0.4)
        }
    }

    func shake() {
        let wiggle = CAKeyframeAnimation(keyPath: "transform.translation.x")
        wiggle.values = [0, -8, 8, -6, 6, -3, 3, 0]

        let pop = CAKeyframeAnimation(keyPath: "transform.scale")
        pop.values = [1.0, 1.1, 1.0]   // briefly shrinks to 90%, then back

        let group = CAAnimationGroup()
        group.animations = [wiggle, pop]
        group.duration = 0.4
        layer.add(group, forKey: "shake")
    }
}
