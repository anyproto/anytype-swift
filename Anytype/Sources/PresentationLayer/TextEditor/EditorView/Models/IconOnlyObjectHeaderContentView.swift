//
//  IconOnlyObjectHeaderContentView.swift
//  IconOnlyObjectHeaderContentView
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class IconOnlyObjectHeaderContentView: UIView, UIContentView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()
    
    private let containerView = UIView()
    private var stackView: UIStackView!
    
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
        case let .icon(icon):
            configureIconState(icon)
        case let .preview(preview):
            configurePreviewState(preview)
        }
    }
    
    private func configureIconState(_ icon: DocumentIconType) {
        activityIndicatorView.hide()

        switch icon {
        case let .basic(basic):
            configureBasicIcon(basic)
        case let .profile(profile):
            configureProfileIcon(profile)
        }
    }
    
    private func configureBasicIcon(_ basicIcon: DocumentIconType.Basic) {
        topConstraint.constant = Constants.basicTopInset
        switch basicIcon {
        case let .emoji(emoji):
            showEmojiView(emoji)
        case let .imageId(imageId):
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
        containerView.addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
    private func configurePreviewState(_ preview: ObjectIconPreviewType) {
        switch preview {
        case let .basic(image):
            topConstraint.constant = Constants.basicTopInset
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
  
}

// MARK: - Private extension

private extension IconOnlyObjectHeaderContentView {
    
    func setupView() {
        containerView.clipsToBounds = true
        
        backgroundColor = .grayscaleWhite
        
        setupLayout()
    }
    
    func setupLayout() {
        stackView = layoutUsing.stack(
            layout: { stack in
                stack.layoutUsing.anchors {
                    $0.leading.equal(
                        to: self.leadingAnchor,
                        constant: Constants.horizontalInset
                    )
                    $0.trailing.equal(
                        to: self.trailingAnchor,
                        constant: -Constants.horizontalInset
                    )
                    $0.bottom.equal(
                        to: self.bottomAnchor,
                        constant: -Constants.bottomInset
                    )
                    self.topConstraint = $0.top.equal(
                        to: self.topAnchor,
                        constant: Constants.basicTopInset
                    )
                }
            },
            builder: {
                $0.hStack(
                    $0.hGap(),
                    containerView,
                    $0.hGap()
                )
            }
        )
    }
    
}

private extension IconOnlyObjectHeaderContentView {
    
    enum Constants {
        static let borderWidth: CGFloat = 4
        static let horizontalInset: CGFloat = 20 - Constants.borderWidth
        static let bottomInset: CGFloat = 16
        static let basicTopInset: CGFloat = 76 - Constants.borderWidth
        static let profileTopInset: CGFloat = 52 - Constants.borderWidth
    }
    
}
