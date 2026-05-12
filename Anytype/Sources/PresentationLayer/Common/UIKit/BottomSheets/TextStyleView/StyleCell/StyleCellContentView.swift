//
//  StyleCellContentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 23.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit
import Assets


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
    private let toggleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(asset: .X18.Disclosure.down))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var labelLeadingConstraint: NSLayoutConstraint!

    private func setupInternalViews() {
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(toggleImageView)
        addSubview(label)

        labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)

        NSLayoutConstraint.activate([
            toggleImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            toggleImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleImageView.widthAnchor.constraint(equalToConstant: 18),
            toggleImageView.heightAnchor.constraint(equalToConstant: 18),

            labelLeadingConstraint,
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

        let textColor: UIColor = configuration.isDisabled ? .Control.tertiary : .Text.primary
        label.textColor = textColor
        toggleImageView.tintColor = textColor

        toggleImageView.isHidden = !configuration.isToggle
        labelLeadingConstraint.constant = configuration.isToggle ? 22 : 10
    }
}
