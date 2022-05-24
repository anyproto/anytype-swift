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
        textField.attributedPlaceholder = NSAttributedString(
            string: "Untitled".localized,
            attributes: [
                .font: UIFont.previewTitle1Medium,
                .foregroundColor: UIColor.textSecondary
            ]
        )
        textField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        return textField
    }()

    private lazy var button: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .action.openToEdit)

        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return button
    }()

    private var debouncer = Debouncer()
    private var viewModel: CreateObjectViewModel
    private var currentText: String = .empty

    init(viewModel: CreateObjectViewModel, openToEditAction: @escaping () -> Void) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        setupLayout()
        
        button.addAction { [weak self] _ in
            guard let self = self else { return }

            self.debouncer.cancel()

            if self.currentText != self.textField.text, let text = self.textField.text  {
                self.viewModel.textDidChange(text)
            }
            openToEditAction()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = heightAnchor.constraint(equalToConstant: 84)
        heightConstraint.priority = .init(rawValue: 999)
        heightConstraint.isActive = true
    }

    @objc private func textDidChange(textField: UITextField) {
        guard let text = textField.text else { return }
        currentText = text

        debouncer.debounce(time: 100) { [weak self] in
            guard let self = self else { return }
            self.viewModel.textDidChange(text)
        }
    }
}
