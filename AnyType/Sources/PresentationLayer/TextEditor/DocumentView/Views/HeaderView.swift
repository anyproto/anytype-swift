//
//  HeaderView.swift
//  AnyType
//
//  Created by Батвинкин Денис Сергеевич on 07.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit

extension DocumentViewController {

    /// Header view with navigation controls
    class HeaderView: UIView {
        private var backAction: () -> Void

        private lazy var backButton: UIButton = {
            let backButton = UIButton()
            backButton.setImage(UIImage(named: "back"), for: .normal)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.addTarget(self, action: #selector(tapBackAction), for: .touchUpInside)

            return backButton
        }()

        private lazy var stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

            return stackView
        }()

        init(backAction: @escaping () -> Void) {
            self.backAction = backAction
            
            super.init(frame: .zero)

            setupView()
            setupLayout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupView() {
            stackView.addArrangedSubview(backButton)
            stackView.addArrangedSubview(UIView())
            addSubview(stackView)
        }

        private func setupLayout() {
            NSLayoutConstraint.activate([
                backButton.widthAnchor.constraint(equalToConstant: 24),
                backButton.heightAnchor.constraint(equalToConstant: 24),

                stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
                stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
                stackView.topAnchor.constraint(equalTo: self.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }

        @objc private func tapBackAction() {
            self.backAction()
        }
    }
}
