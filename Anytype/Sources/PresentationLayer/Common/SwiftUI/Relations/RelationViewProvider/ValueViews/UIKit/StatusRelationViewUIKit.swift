//
//  StatusRelationViewUIKit.swift
//  Anytype
//
//  Created by Denis Batvinkin on 13.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class StatusRelationViewUIKit: UIView {
    let statusOption: Relation.Status.Option?
    let hint: String
    let style: RelationStyle

    private var currentView: UIView!


    // MARK: - Lifecycle

    init(statusOption: Relation.Status.Option?, hint: String, style: RelationStyle) {
        self.statusOption = statusOption
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
        currentView.intrinsicContentSize
    }

    // MARK: - Setup view

    private func setupViews() {
        if let statusOption = statusOption {
            let textView = AnytypeLabel(style: style.font)
            textView.textColor = statusOption.color
            textView.numberOfLines = 1
            textView.setText(statusOption.text)
            currentView = textView
        } else {
            let placeholder = RelationPlaceholderViewUIKit(hint: hint, style: style)
            currentView = placeholder
        }
        addSubview(currentView) {
            $0.pinToSuperview()
        }
    }
}
