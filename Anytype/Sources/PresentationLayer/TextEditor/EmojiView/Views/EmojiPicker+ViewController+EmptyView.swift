//
//  EmptyView.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 4/30/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit

extension EmojiPicker.ViewController {
    
    class EmptyView: UIView {
        
        struct Resource {
            var titleText: String = "There is no emoji"
            var descriptionText: String = "Try to find a new one or upload your image"
            
            func title(with keyword: String) -> String {
                return "\(titleText) named '\(keyword)'"
            }
        }
     
        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.textColor = .grayscale90
            label.textAlignment = .center
            return label
        }()
        
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.textColor = #colorLiteral(red: 0.6745098039, green: 0.662745098, blue: 0.5882352941, alpha: 1)
            label.textAlignment = .center
    
            return label
        }()
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        var resource: Resource = .init()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            configure()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configure() {
            self.stackView.addArrangedSubview(self.titleLabel)
            self.stackView.addArrangedSubview(self.descriptionLabel)
            self.addSubview(stackView)
            
            setupLayout()
            setupUI()
        }
        
        private func setupUI() {
            self.titleLabel.text = self.resource.titleText
            self.descriptionLabel.text = self.resource.descriptionText
        }
        
        private func setupLayout() {
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: self.topAnchor)
            ])
        }
        
        public func updateTitle(with keyword: String) {
            self.titleLabel.text = self.resource.title(with: keyword)
        }
        
    }
    
}

