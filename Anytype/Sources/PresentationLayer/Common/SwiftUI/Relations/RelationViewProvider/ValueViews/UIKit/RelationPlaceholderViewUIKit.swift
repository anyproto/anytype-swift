//
//  RelationPlaceholderViewUIKit.swift
//  Anytype
//
//  Created by Denis Batvinkin on 13.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class RelationPlaceholderViewUIKit: UIView {
    let hint: String
    let type: RelationPlaceholderType

    private lazy var textView = AnytypeLabel(style: .callout)


    // MARK: - Lifecycle

    init(hint: String, type: RelationPlaceholderType) {
        self.hint = hint
        self.type = type

        super.init(frame: .zero)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        textView.intrinsicContentSize
    }

    // MARK: - Setup view

    private func setupViews() {
        setupStyle()

        addSubview(textView) {
            $0.pinToSuperview()
        }
    }

    private func setupStyle() {
        textView.numberOfLines = 1

        switch type {
        case .hint:
            textView.textColor = .textTertiary
            textView.setText(hint)
        case .empty:
            backgroundColor = .backgroundPrimary
        }
    }
}
