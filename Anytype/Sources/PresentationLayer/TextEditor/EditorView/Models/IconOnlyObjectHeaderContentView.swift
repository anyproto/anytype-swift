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
    private var contentView: UIView!
    private var stackView: UIStackView!
    
    // MARK: - Private variables
    
    private var appliedConfiguration: IconOnlyObjectHeaderConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard let configuration = newValue as? IconOnlyObjectHeaderConfiguration,
                  appliedConfiguration != configuration else {
                return
            }
            
            // TODO: implement apply
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
        switch configuration.icon {
        case let .icon(icon):
            configureIconState(icon)
        case let .preview(preview):
            configurePreviewState(preview)
        }
        
        appliedConfiguration = configuration
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
        switch basicIcon {
        case let .emoji(emoji):
            showEmojiView(emoji)
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
        
        iconEmojiView.configure(model: emoji.value)
                
        let cornerRadius = iconEmojiView.layer.cornerRadius
        containerView.layer.cornerRadius = cornerRadius
//        configureBorder(cornerRadius: cornerRadius)
        
        containerView.removeAllSubviews()
        containerView.addSubview(iconEmojiView) {
            $0.pinToSuperview()
        }
    }
    
    private func showImageView(_ model: DocumentIconImageView.Model) {
        let iconImageView = DocumentIconImageView()

        iconImageView.configure(model: model)
        
        
        let cornerRadius = iconImageView.layer.cornerRadius
        containerView.layer.cornerRadius = cornerRadius
//        configureBorder(cornerRadius: cornerRadius)
        
        containerView.removeAllSubviews()
        containerView.addSubview(iconImageView) {
            $0.pinToSuperview()
        }
    }
    
    private func configurePreviewState(_ preview: ObjectIconPreviewType) {
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
                        constant: Constants.horizontalInset
                    )
                    $0.bottom.equal(to: self.bottomAnchor, constant: 16)
                    $0.top.equal(to: self.topAnchor, constant: 52)
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
    }
    
}
