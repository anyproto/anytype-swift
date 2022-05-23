//
//  CreateObjectView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 20.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class CreateObjectView: UIView {

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.font = .previewTitle1Medium
        textField.clearButtonMode = .always
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Untitled".localized,
            attributes: [
                .font: UIFont.previewTitle1Medium,
                .foregroundColor: UIColor.textSecondary
            ]
        )
        return textField
    }()

    private lazy var button: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .action.openToEdit)

        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.alignment = .center

        hstack.addArrangedSubview(textField)
        hstack.addArrangedSubview(button)

        addSubview(hstack) {
            $0.pinToSuperview(insets: .init(top: 0, left: 20, bottom: 0, right: -20))
        }

        translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = heightAnchor.constraint(equalToConstant: 84)
        heightConstraint.priority = .init(rawValue: 999)
        heightConstraint.isActive = true
    }
}
