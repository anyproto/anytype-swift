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

        colorView.layer.cornerRadius = colorView.bounds.width / 2
        colorView.layer.cornerCurve = .circular

        backgroundView.layer.cornerRadius =  backgroundView.bounds.width / 2
        backgroundView.layer.cornerCurve = .circular
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

        backgroundView.layer.borderColor = UIColor.grayscale30.cgColor
        backgroundView.layer.borderWidth = 1.5

        addSubview(backgroundView)
        addSubview(colorView)

        isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 44),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor),

            backgroundView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: -4),
            backgroundView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: -4),
            backgroundView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 4),
            backgroundView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 4),
        ])
    }

    private var appliedConfiguration: StyleColorCellContentConfiguration = .init()

    private func apply(configuration: StyleColorCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        colorView.backgroundColor = configuration.color
        colorView.layer.borderWidth = 0.0
        backgroundView.isHidden = !configuration.isSelected

        if colorView.backgroundColor == UIColor.grayscaleWhite {
            colorView.layer.borderWidth = 1.0
            colorView.layer.borderColor = UIColor.grayscale30.cgColor
        }
    }
}
