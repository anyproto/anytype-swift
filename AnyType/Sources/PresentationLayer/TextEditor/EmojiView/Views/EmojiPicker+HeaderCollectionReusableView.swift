//
//  EmojiHeaderCollectionReusableView.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 4/30/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit

extension EmojiPicker {

    class HeaderCollectionReusableView: UICollectionReusableView {
        
        static let reuseIdentifer = "EmojiHeaderCollectionReusableView"
        
        var style: Style = .presentation
        
        lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = self.style.font()
            label.textColor = self.style.textColor()
            label.textAlignment = .center
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
            setupElements()
            setupLayout()
        }
        
        private func setupElements() {
            self.addSubview(titleLabel)
        }
        
        private func setupLayout() {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
            
    }
}

// MARK: - Style
extension EmojiPicker.HeaderCollectionReusableView {
    enum Style {
        case presentation
        
        func font() -> UIFont {
            .boldSystemFont(ofSize: 14)
        }
        
        func textColor() -> UIColor {
            #colorLiteral(red: 0.730399251, green: 0.7181095481, blue: 0.6533814073, alpha: 1) //#ACA996
        }
    }
}
