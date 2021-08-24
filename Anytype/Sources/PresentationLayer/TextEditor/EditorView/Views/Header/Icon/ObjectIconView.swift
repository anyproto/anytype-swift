//
//  ObjectIconView.swift
//  ObjectIconView
//
//  Created by Konstantin Mordan on 11.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels

final class ObjectIconView: UIView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()
    
    private let containerView = UIView()
    
    // MARK: - Private variables
    
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ConfigurableView

extension ObjectIconView: ConfigurableView {

    func configure(model: ObjectIcon) {
        switch model {
        case let .icon(icon, alignment):
            configureIconState(icon, alignment)
        case let .preview(preview, alignment):
            configurePreviewState(preview, alignment)
        }
    }
    
    private func configureIconState(_ icon: DocumentIconType,
                                    _ alignment: LayoutAlignment) {
        handleAlignment(alignment)
        activityIndicatorView.hide()

        switch icon {
        case let .basic(basic):
            configureBasicIcon(basic)
        case let .profile(profile):
            configureProfileIcon(profile)
        case let .emoji(emoji):
            showEmojiView(emoji)
        }
    }
    
    private func configureBasicIcon(_ basicIcon: DocumentIconType.Basic) {
        switch basicIcon {
        case let .imageId(imageId):
            showImageView(.basic(.imageId(imageId)))
        }
    }
    
    private func configureProfileIcon(_ profileIcon: DocumentIconType.Profile) {
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
            $0.leading.equal(
                to: containerView.leadingAnchor,
                constant: Constants.borderWidth
            )
            $0.top.equal(
                to: containerView.topAnchor,
                constant: Constants.borderWidth
            )
        }
        contentView.addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
    private func configurePreviewState(_ preview: ObjectIconPreviewType, _ alignment: LayoutAlignment) {
        handleAlignment(alignment)
        
        switch preview {
        case let .basic(image):
            showImageView(.basic(.preview(image)))
        case let .profile(image):
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

private extension ObjectIconView {
    
    func setupView() {
        containerView.clipsToBounds = true
        
        containerView.backgroundColor = .grayscaleWhite
        
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(containerView) {
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            
            leadingConstraint = $0.leading.equal(
                to: leadingAnchor
            )
            
            centerConstraint = $0.centerX.equal(
                to: centerXAnchor,
                activate: false
            )
            trailingConstraint =  $0.trailing.equal(
                to: trailingAnchor,
                activate: false
            )
        }
    }
    
}

extension ObjectIconView {
    
    enum Constants {
        static let borderWidth: CGFloat = 4
    }
    
}
