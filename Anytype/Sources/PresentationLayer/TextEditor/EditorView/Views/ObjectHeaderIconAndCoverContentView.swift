//
//  ObjectHeaderIconAndCoverContentView.swift
//  ObjectHeaderIconAndCoverContentView
//
//  Created by Konstantin Mordan on 10.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//


import UIKit
import BlocksModels

final class ObjectHeaderIconAndCoverContentView: UIView, UIContentView {
    
    // MARK: - Views
    
    private let iconView = ObjectIconView()
    private let coverView = ObjectCoverView()
    
    // MARK: - Private variables
    
    private var bottomConstraint: NSLayoutConstraint!
    private var appliedConfiguration: ObjectHeaderIconAndCoverConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? ObjectHeaderIconAndCoverConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration: configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: ObjectHeaderIconAndCoverConfiguration) {
        super.init(frame: .zero)
        
        setupView()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ObjectHeaderIconAndCoverContentView {

    func apply(configuration: ObjectHeaderIconAndCoverConfiguration) {
        appliedConfiguration = configuration
        
        switch configuration.icon {
        case let .icon(icon, _):
            configureIconTopInset(icon)
        case let .preview(preview, _):
            configurePreviewTopInset(preview)
        }
        
        iconView.configure(model: configuration.icon)
        coverView.configure(
            model: .init(
                cover: configuration.cover,
                maxWidth: configuration.maxWidth
            )
        )
    }
    
    private func configureIconTopInset(_ icon: DocumentIconType) {
        switch icon {
        case .basic:
            bottomConstraint.constant = -Constants.bottomInset
            coverView.configure(bottomInset: .basic)
            
        case .profile:
            bottomConstraint.constant = -Constants.profileBottomInset
            coverView.configure(bottomInset: .profile)
        }
    }
    
    private func configurePreviewTopInset(_ preview: ObjectIconPreviewType) {
        switch preview {
        case .basic:
            bottomConstraint.constant = -Constants.bottomInset
            coverView.configure(bottomInset: .basic)

        case .profile:
            bottomConstraint.constant = -Constants.profileBottomInset
            coverView.configure(bottomInset: .profile)
        }
    }
    
}

private extension ObjectHeaderIconAndCoverContentView {

    func setupView() {
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(coverView) {
            $0.pinToSuperview()
        }
        
        addSubview(iconView) {
            $0.leading.equal(
                to: leadingAnchor,
                constant: Constants.horizontalInset
            )
            $0.trailing.equal(
                to: trailingAnchor,
                constant: -Constants.horizontalInset
            )
            
            bottomConstraint = $0.bottom.equal(
                to: self.bottomAnchor,
                constant: -Constants.bottomInset
            )
        }
    }
    
}

private extension ObjectHeaderIconAndCoverContentView {
    
    enum Constants {
        static let horizontalInset: CGFloat = 20 - ObjectIconView.Constants.borderWidth
        static let bottomInset: CGFloat = 16 - ObjectIconView.Constants.borderWidth
        static let profileBottomInset: CGFloat = 12 - ObjectIconView.Constants.borderWidth
    }
    
}
