//
//  CreateObjectView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 20.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class CreateObjectView: UIView {
    private let textField = UITextField()
    private let button = ButtonsFactory.makeButton(image: .action.openToEdit)

    private let viewModel: CreateObjectViewModel

    init(viewModel: CreateObjectViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        setupButton()
        setupTextField()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    private func setupLayout() {
        layoutUsing.stack {
            $0.alignment = .center
            $0.edgesToSuperview(insets: .init(top: 0, left: 20, bottom: 0, right: 20))
        } builder: {
            $0.hStack(
                textField,
                $0.hGap(),
                button
            )
        }

        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = heightAnchor.constraint(equalToConstant: 68)
        heightConstraint.priority = .init(rawValue: 999)
        heightConstraint.isActive = true
    }

    private func setupButton() {
        button.addAction { [weak self] _ in
            guard let self = self else { return }

            self.viewModel.openToEditAction(with: self.textField.text ?? .empty)
        }
    }

    private func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.font = .previewTitle1Medium
        textField.attributedPlaceholder = NSAttributedString(
            string: "Untitled".localized,
            attributes: [
                .font: UIFont.previewTitle1Medium,
                .foregroundColor: UIColor.textSecondary
            ]
        )
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
    }

    @objc private func textDidChange(textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.textDidChange(text)
    }
}

extension CreateObjectView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.returnDidTap()
        return false
    }
}
