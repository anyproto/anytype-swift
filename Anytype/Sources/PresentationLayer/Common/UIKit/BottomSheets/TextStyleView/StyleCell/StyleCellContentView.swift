//
//  StyleCellContentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 23.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class StyleCellContentView: UIView, UIContentView {
    init(configuration: StyleCellContentConfiguration) {
        super.init(frame: .zero)
        setupInternalViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? StyleCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let label = UILabel()

    private func setupInternalViews() {
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private var appliedConfiguration: StyleCellContentConfiguration!

    private func apply(configuration: StyleCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        label.text = configuration.text
        label.font = configuration.font

        label.textColor = configuration.isDisabled ? .Control.tertiary : .Text.primary
    }
}
