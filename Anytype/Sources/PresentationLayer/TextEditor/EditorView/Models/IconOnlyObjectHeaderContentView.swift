//
//  IconOnlyObjectHeaderContentView.swift
//  IconOnlyObjectHeaderContentView
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import BlocksModels

final class IconOnlyObjectHeaderContentView: UIView, UIContentView {
    
    // MARK: - Views
    
    private let iconView = ObjectIconView()

    // MARK: - Private variables
    
    private var topConstraint: NSLayoutConstraint!
    
    private var appliedConfiguration: IconOnlyObjectHeaderConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? IconOnlyObjectHeaderConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration: configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: IconOnlyObjectHeaderConfiguration) {
        super.init(frame: .zero)
        
        setupView()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension IconOnlyObjectHeaderContentView {

    func apply(configuration: IconOnlyObjectHeaderConfiguration) {
        appliedConfiguration = configuration
        
        switch configuration.icon {
        case let .icon(icon, alignment):
            configureIconState(icon, alignment)
        case let .preview(preview, alignment):
            configurePreviewState(preview, alignment)
        }
        
        iconView.configure(model: configuration.icon)
    }
    
    private func configureIconState(_ icon: DocumentIconType,
                                    _ alignment: LayoutAlignment) {
        switch icon {
        case let .basic(basic):
            switch basic {
            case .emoji:
                topConstraint.constant = Constants.basicEmojiTopInset
            case .imageId:
                topConstraint.constant = Constants.basicIconTopInset
            }
            
        case .profile:
            topConstraint.constant = Constants.profileTopInset
        }
    }
    
    private func configurePreviewState(_ preview: ObjectIconPreviewType,
                                       _ alignment: LayoutAlignment) {
        switch preview {
        case .basic:
            topConstraint.constant = Constants.basicIconTopInset
        case .profile:
            topConstraint.constant = Constants.profileTopInset
        }
    }
  
}

// MARK: - Private extension

private extension IconOnlyObjectHeaderContentView {
    
    func setupView() {
        backgroundColor = .grayscaleWhite
        
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(iconView) {
            $0.leading.equal(
                to: leadingAnchor,
                constant: Constants.horizontalInset
            )
            $0.trailing.equal(
                to: trailingAnchor,
                constant: -Constants.horizontalInset
            )
            
            topConstraint = $0.top.equal(
                to: self.topAnchor,
                constant: Constants.basicEmojiTopInset
            )
            
            $0.bottom.equal(
                to: self.bottomAnchor,
                constant: -Constants.bottomInset
            )
        }
    }
    
}

private extension IconOnlyObjectHeaderContentView {
    
    enum Constants {
        static let horizontalInset: CGFloat = 20 - ObjectIconView.Constants.borderWidth
        static let bottomInset: CGFloat = 16 - ObjectIconView.Constants.borderWidth
        
        static let basicIconTopInset: CGFloat = 60 - ObjectIconView.Constants.borderWidth
        static let basicEmojiTopInset: CGFloat = 76 - ObjectIconView.Constants.borderWidth
        static let profileTopInset: CGFloat = 52 - ObjectIconView.Constants.borderWidth
    }
    
}
