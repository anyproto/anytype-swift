//
//  TextRelationViewUIKit.swift
//  Anytype
//
//  Created by Denis Batvinkin on 08.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class TextRelationViewUIKit: UIView {
    let text: String
    let hint: String
    let style: RelationStyle

    private lazy var textView = AnytypeLabel(style: style.font)


    // MARK: - Lifecycle

    init(text: String?, hint: String, style: RelationStyle) {
        self.text = text ?? ""
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
        return CGSize(width: textView.intrinsicContentSize.width, height: textView.intrinsicContentSize.height)
    }

    // MARK: - Setup view

    private func setupViews() {
        textView.textColor = style.uiKitFontColor
        textView.setText(text)
        textView.numberOfLines = style.allowMultiLine ? 0 : 1

        addSubview(textView) {
            $0.pinToSuperview()
        }
    }
}
