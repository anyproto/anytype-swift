//
//  RelationPlaceholderViewUIKit.swift
//  Anytype
//
//  Created by Denis Batvinkin on 13.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class RelationPlaceholderViewUIKit: UIView {
    
    private lazy var textView: AnytypeLabel = {
        AnytypeLabel(style: style.hintFont)
    }()

    private let hint: String
    private let style: RelationStyle

    // MARK: - Lifecycle

    init(hint: String, style: RelationStyle) {
        self.hint = hint
        self.style = style

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

        switch style.placeholderType {
        case .hint:
            textView.textColor = .textTertiary
            textView.setText(hint)
        case .empty:
            backgroundColor = .BackgroundNew.primary
        case let .clear(withHint):
            textView.textColor = .textSecondary
            if withHint {
                textView.setText(hint)
            }
        }
    }
}
