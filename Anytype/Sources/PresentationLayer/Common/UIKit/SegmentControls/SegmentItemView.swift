//
//  SegmentItemView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 28.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class SegmentItemView: UIView {
    typealias ActionHandler = () -> Void

    private enum Constants {
        static let labelEdgeInsets = UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)
    }

    private var actionHandler: ActionHandler?
    private var label: UILabel = .init()

    init(title: String) {
        super.init(frame: .zero)

        label.text = title

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let width = label.intrinsicContentSize.width + Constants.labelEdgeInsets.left + Constants.labelEdgeInsets.right
        let height = label.intrinsicContentSize.height + Constants.labelEdgeInsets.top + Constants.labelEdgeInsets.bottom
        return CGSize(width: width, height: height)
    }

    func setActionHandler(_ actionHandler: @escaping ActionHandler) {
        self.actionHandler = actionHandler
    }

    private func setupViews() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleAction))
        addGestureRecognizer(tapGestureRecognizer)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bodyMedium
        label.tintColor = UIColor.grayscale90

        addSubview(label)
        label.edgesToSuperview(insets: Constants.labelEdgeInsets)
    }

    @objc private func handleAction() {
        actionHandler?()
    }
}
