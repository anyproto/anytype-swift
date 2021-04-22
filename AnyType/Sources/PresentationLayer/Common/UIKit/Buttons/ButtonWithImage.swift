//
//  ButtonWithImage.swift
//  AnyType
//
//  Created by Denis Batvinkin on 12.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

/// Any type button
final class ButtonWithImage: UIControl {
    private(set) var label: UILabel = .init()
    private(set) var imageView: UIImageView = .init()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        label.font = UIFont.bodyFont
        label.textColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.Colors.grey.color()

        addSubview(label)
        addSubview(imageView)

        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        label.isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 4),
            imageView.widthAnchor.constraint(equalToConstant: 8),
            imageView.heightAnchor.constraint(equalToConstant: 8),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
    }

}
