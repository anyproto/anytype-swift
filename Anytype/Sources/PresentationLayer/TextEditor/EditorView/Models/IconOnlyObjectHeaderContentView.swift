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
    
    private let activityIndicatorView = ActivityIndicatorView()
    
    private let containerView = UIView()
    private var stackView: UIStackView!
    
    // MARK: - Private variables
    
    private var topConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
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
    }
    
    private func configureIconState(_ icon: DocumentIconType, _ alignment: LayoutAlignment) {
        handleAlignment(alignment)
        activityIndicatorView.hide()

        switch icon {
        case let .basic(basic):
            configureBasicIcon(basic)
        case let .profile(profile):
            configureProfileIcon(profile)
        }
    }
    
    private func configureBasicIcon(_ basicIcon: DocumentIconType.Basic) {
        switch basicIcon {
        case let .emoji(emoji):
            topConstraint.constant = Constants.basicEmojiTopInset
            showEmojiView(emoji)
        case let .imageId(imageId):
            topConstraint.constant = Constants.basicIconTopInset
            showImageView(.basic(.imageId(imageId)))
        }
    }
    
    private func configureProfileIcon(_ profileIcon: DocumentIconType.Profile) {
        topConstraint.constant = Constants.profileTopInset
        switch profileIcon {
        case let .imageId(imageId):
            showImageView(.profile(.imageId(imageId)))
        case let .placeholder(character):
            showImageView(.profile(.placeholder(character)))
        }
    }
    
    private func showEmojiView(_ emoji: IconEmoji) {
        let iconEmojiView = DocumentIconEmojiView()
            .configured(with: emoji.value)
                
        addContentViewToContainer(iconEmojiView)
    }
    
    private func showImageView(_ model: DocumentIconImageView.Model) {
        let iconImageView = DocumentIconImageView()
            .configured(with: model)
        
        addContentViewToContainer(iconImageView)
    }
    
    private func addContentViewToContainer(_ contentView: UIView) {
        let cornerRadius = contentView.layer.cornerRadius
        
        containerView.layer.cornerRadius = cornerRadius + Constants.borderWidth
                
        containerView.removeAllSubviews()
        containerView.addSubview(contentView) {
            $0.center(in: containerView)
            $0.leading.equal(to: containerView.leadingAnchor, constant: Constants.borderWidth)
            $0.top.equal(to: containerView.topAnchor, constant: Constants.borderWidth)
        }
        contentView.addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
    private func configurePreviewState(_ preview: ObjectIconPreviewType, _ alignment: LayoutAlignment) {
        handleAlignment(alignment)
        
        switch preview {
        case let .basic(image):
            topConstraint.constant = Constants.basicIconTopInset
            showImageView(.basic(.preview(image)))
        case let .profile(image):
            topConstraint.constant = Constants.profileTopInset
            showImageView(.profile(.preview(image)))
        }
        
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.show()
    }
    
    private func handleAlignment(_ alignment: LayoutAlignment) {
        switch alignment {
        case .left:
            leadingConstraint.isActive = true
            centerConstraint.isActive = false
            trailingConstraint.isActive = false
        case .center:
            leadingConstraint.isActive = false
            centerConstraint.isActive = true
            trailingConstraint.isActive = false
        case .right:
            leadingConstraint.isActive = false
            centerConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }
  
}

// MARK: - Private extension

private extension IconOnlyObjectHeaderContentView {
    
    func setupView() {
        containerView.clipsToBounds = true
        
        containerView.backgroundColor = .grayscaleWhite
        backgroundColor = .grayscaleWhite
        
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(containerView) {
            leadingConstraint = $0.leading.equal(
                to: leadingAnchor,
                constant: Constants.horizontalInset
            )
            
            centerConstraint = $0.centerX.equal(
                to: centerXAnchor,
                activate: false
            )
            trailingConstraint =  $0.trailing.equal(
                to: trailingAnchor,
                constant: -Constants.horizontalInset,
                activate: false
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
        static let borderWidth: CGFloat = 4
        
        static let horizontalInset: CGFloat = 20 - Constants.borderWidth
        static let bottomInset: CGFloat = 16 - Constants.borderWidth
        
        static let basicIconTopInset: CGFloat = 108 - Constants.borderWidth
        static let basicEmojiTopInset: CGFloat = 124 - Constants.borderWidth
        static let profileTopInset: CGFloat = 92 - Constants.borderWidth
    }
    
}

private extension LayoutAlignment {
    
    var asStackViewAlignment: UIStackView.Alignment {
        switch self {
        case .left:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }
    
}
