//
//  AnytypeLabel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit


class AnytypeLabel: UIView {
    private var topLabelConstraint: NSLayoutConstraint?
    private var bottomLabelConstraint: NSLayoutConstraint?

    private var anytypeText: UIKitAnytypeText = .init(text: "", style: .bodyRegular)
    private let label: UILabel = .init()

    var textAlignment: NSTextAlignment {
        set {
            label.textAlignment = newValue
        }
        get {
            label.textAlignment
        }
    }

    var textColor: UIColor {
        set {
            label.textColor = newValue
        }
        get {
            label.textColor
        }
    }

    // MARK: - Life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height + anytypeText.verticalSpacing * 2)
    }

    // MARK: - Setup view

    private func setupView() {
        label.numberOfLines = 0

        addSubview(label) {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            topLabelConstraint = $0.top.equal(to: topAnchor, constant: anytypeText.verticalSpacing)
            bottomLabelConstraint = $0.bottom.equal(to: bottomAnchor, constant: anytypeText.verticalSpacing)
        }
    }

    private func updateLabel() {
        label.attributedText = anytypeText.attrString
        topLabelConstraint?.constant = anytypeText.verticalSpacing
        bottomLabelConstraint?.constant = anytypeText.verticalSpacing
    }

    // MARK: - Public methods

    func setText(_ text: String, style: AnytypeFont) {
        anytypeText = UIKitAnytypeText(text: text, style: style)
        updateLabel()
    }

    func setText(_ text: NSAttributedString, style: AnytypeFont) {
        anytypeText = UIKitAnytypeText(attributedString: text, style: style)
        updateLabel()
    }

    func setText(_ text: UIKitAnytypeText) {
        anytypeText = text
        updateLabel()
    }
}
