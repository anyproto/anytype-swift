//
//  SearchTextFieldView.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 4/27/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine

class SearchTextFieldView: UIView, ObservableObject {
    
    @Published var text: String = ""
    
    var style: Style = .presentation
    var layout: Layout = .init()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.layout.stackView.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Filter"
        textField.textColor = self.style.textColor()
        textField.font = self.style.font()
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        return textField
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.searchIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init() {
        super.init(frame: .zero)

        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        backgroundColor = self.style.backgroundColor()
        layer.cornerRadius = self.layout.cornerRadius
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textField)
        addSubview(stackView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: self.layout.iconImageViewWidth),
        
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: self.layout.stackView.leftPadding),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        self.text = textField.text ?? ""
    }

}

// MARK: - UITextFieldDelegate
extension SearchTextFieldView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Style
extension SearchTextFieldView {
    enum Style {
        case presentation
        
        func font() -> UIFont {
            .preferredFont(forTextStyle: .body)
        }
        
        func textColor() -> UIColor {
            .textPrimary
        }
        
        func backgroundColor() -> UIColor {
            .strokeTransperent
        }
    }
}

// MARK: - Layout
extension SearchTextFieldView {
    struct Layout {
        var cornerRadius: CGFloat = 8
        var iconImageViewWidth: CGFloat = 24
        
        struct StackView {
            var spacing: CGFloat = 4
            var leftPadding: CGFloat = 8
        }
        var stackView: StackView = .init()
    }
}
