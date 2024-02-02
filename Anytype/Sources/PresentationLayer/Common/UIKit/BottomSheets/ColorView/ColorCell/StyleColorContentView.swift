//
//  StyleColorContentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 27.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class StyleColorContentView: UIView, UIContentView {
    init(configuration: StyleColorCellContentConfiguration) {
        super.init(frame: .zero)

        setupInternalViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        colorView.layer.cornerRadius = 6
        colorView.layer.cornerCurve = .continuous

        backgroundView.layer.cornerRadius =  9
        backgroundView.layer.cornerCurve = .continuous
    }

    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? StyleColorCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let colorView = UIButton()
    private let backgroundView = UIView()

    private func setupInternalViews() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        colorView.dynamicBorderColor = UIColor.Text.tertiary
        colorView.layer.borderWidth = 1

        backgroundView.dynamicBorderColor = UIColor.Shape.secondary
        backgroundView.layer.borderWidth = 3

        addSubview(backgroundView)
        addSubview(colorView)

        isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 26),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor),

            backgroundView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: -3),
            backgroundView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: -3),
            backgroundView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 3),
            backgroundView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 3),
        ])
    }

    private var appliedConfiguration: StyleColorCellContentConfiguration!

    private func apply(configuration: StyleColorCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        switch configuration.colorItem {
        case .background:
            let title = configuration.colorItem.color == .Background.primary ? "⁄" : ""
            colorView.setTitle(title, for: .normal)
            colorView.setTitleColor(.Text.tertiary, for: .normal)
            colorView.backgroundColor = configuration.colorItem.color
        case .text:
            colorView.setTitle(Loc.StyleMenu.Color.TextColor.placeholder, for: .normal)
            colorView.titleLabel?.font = .bodyRegular
            colorView.setTitleColor(configuration.colorItem.color, for: .normal)
            colorView.backgroundColor = .clear
        }
        backgroundView.isHidden = !configuration.isSelected
    }
}
