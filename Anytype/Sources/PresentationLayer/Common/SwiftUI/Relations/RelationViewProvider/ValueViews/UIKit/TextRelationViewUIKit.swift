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
    let style: RelationStyle

    private lazy var textView = AnytypeLabel(style: style.font)
  
    // MARK: - Lifecycle

    init(text: String, style: RelationStyle) {
        self.text = text
        self.style = style

        super.init(frame: .zero)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup view

    private func setupViews() {
        textView.textColor = style.uiFontColorWithError
        textView.setText(text)
        textView.numberOfLines = style.allowMultiLine ? 0 : 1

        addSubview(textView) {
            $0.pinToSuperview()
        }
    }
}
