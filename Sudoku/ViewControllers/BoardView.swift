//
//  BoardView.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/19/26.
//

import UIKit

protocol BoardViewDelegate: AnyObject {
    func boardView(_ boardView: BoardView, didSelectRow row: Int, column: Int)
}

final class BoardView: UIView {
    weak var delegate: BoardViewDelegate?
    private var cells: [CellView] = []

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }  // storyboard path

    private func setup() {
        backgroundColor = .label  // grid line color
        for _ in 0..<81 {
            let cell = CellView()
            addSubview(cell)
            cells.append(cell)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    func cell(row: Int, column: Int) -> CellView { cells[row * 9 + column] }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("BoardView bounds:", bounds)
        let thin: CGFloat = 1, thick: CGFloat = 3
        let side = min(bounds.width, bounds.height)
        let size = (side - 4 * thick - 6 * thin) / 9

        func offset(_ i: Int) -> CGFloat {
            thick + CGFloat(i) * size + CGFloat(i - i / 3) * thin + CGFloat(i / 3) * thick
        }
        for row in 0..<9 {
            for col in 0..<9 {
                cell(row: row, column: col).frame =
                    CGRect(x: offset(col), y: offset(row), width: size, height: size)
            }
        }
        
            // ...existing frame code...
        print("Cell 0:", cells[0].frame, "Cell 80:", cells[80].frame)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        if let i = cells.firstIndex(where: { $0.frame.contains(point) }) {
            delegate?.boardView(self, didSelectRow: i / 9, column: i % 9)
        }
    }
}
