//
//  UnsupportedBlockView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 06.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import BlocksModels
import UIKit
import AnytypeCore

class UnsupportedBlockView: UIView & UIContentView {
    private let fontStyle: AnytypeFont = .calloutRegular
    private var currentConfiguration: UnsupportedBlockContentConfiguration

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? UnsupportedBlockContentConfiguration else {
                anytypeAssertionFailure("Wrong configuration: \(newValue) for block file empty view")
                return
            }
            self.currentConfiguration = newConfiguration
            apply(configuration: newConfiguration)
        }
    }

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .textTertiary
        return label
    }()

    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TextEditor/questionMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init(configuration: UnsupportedBlockContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(icon) {
            $0.leading.equal(to: leadingAnchor, constant: Layout.iconLeftSpacing)
            $0.height.equal(to: Layout.iconSize)
            $0.width.equal(to: Layout.iconSize)
            $0.centerY.equal(to: centerYAnchor)
        }

        let text = UIKitAnytypeText(text: currentConfiguration.text, style: fontStyle)

        addSubview(label) {
            $0.top.equal(to: topAnchor, constant: Layout.labelTopBottomSpacing + text.verticalSpacing)
            $0.bottom.equal(to: bottomAnchor, constant: -(Layout.labelTopBottomSpacing + text.verticalSpacing))
            $0.leading.equal(to: icon.trailingAnchor, constant: Layout.iconToTextPadding)
        }
    }

    // MARK: - New configuration
    func apply(configuration: UnsupportedBlockContentConfiguration) {
        label.attributedText =  UIKitAnytypeText(text: configuration.text, style: fontStyle).attrString
    }
}


extension UnsupportedBlockView {
    private enum Layout {
        static let labelTopBottomSpacing: CGFloat = 5
        static let iconToTextPadding: CGFloat = 9
        static let iconSize: CGFloat =  18
        static let iconLeftSpacing: CGFloat =  23.11
    }
}
