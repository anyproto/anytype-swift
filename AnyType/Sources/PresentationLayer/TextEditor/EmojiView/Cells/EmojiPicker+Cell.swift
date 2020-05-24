//
//  EmojiPickerViewCell.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 4/27/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit

extension EmojiPicker {
    
    class Cell: UICollectionViewCell {
        
        static let reuseIdentifer = "EmojiPickerViewCellReuseIdentifer"
        
        var style: Style = .presentation
        
        lazy var emojiLabel: UILabel = {
            let label = UILabel()
            label.font = self.style.font()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            configure()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configure() {
            backgroundColor = .clear
            contentView.addSubview(emojiLabel)
            setupLayout()
        }
        
        private func setupLayout() {
            NSLayoutConstraint.activate([
                emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
                emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
    }
}

// MARK: - Style
extension EmojiPicker.Cell {
    enum Style {
        case presentation
        
        func font() -> UIFont {
            .systemFont(ofSize: 40)
        }
    }
}
