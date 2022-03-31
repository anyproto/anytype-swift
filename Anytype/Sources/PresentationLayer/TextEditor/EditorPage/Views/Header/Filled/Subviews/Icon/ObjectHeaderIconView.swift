//
//  ObjectIconView.swift
//  ObjectIconView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class ObjectHeaderIconView: UIView {
    
    // MARK: - Private variables
    
    private let activityIndicatorView = ActivityIndicatorView()
        
    private var containerViewHeightConstraint: NSLayoutConstraint!
    private var containerViewWidthConstraint: NSLayoutConstraint!
    
    private let containerView = UIView()
    
    private let iconImageView = ObjectIconImageView()
    private let previewImageView = UIImageView()
    
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

extension ObjectHeaderIconView: ConfigurableView {

    enum Model: Hashable {
        case icon(ObjectIconType)
        case basicPreview(UIImage?)
        case profilePreview(UIImage?)
    }

    func configure(model: Model) {
        switch model {
        case .icon(let objectIconType):
            showObjectIconType(objectIconType)
            
        case .basicPreview(let uIImage):
            showImagePreview(
                image: uIImage,
                imageGuideline: ObjectIconImageUsecase.openedObject.objectIconImageGuidelineSet.basicImageGuideline
            )
            
        case .profilePreview(let uIImage):
            showImagePreview(
                image: uIImage,
                imageGuideline: ObjectIconImageUsecase.openedObject.objectIconImageGuidelineSet.profileImageGuideline
            )
        }
    }
    
}

private extension ObjectHeaderIconView {
        
    func showObjectIconType(_ objectIconType: ObjectIconType) {
        let model = ObjectIconImageModel(
            iconImage: ObjectIconImage.icon(objectIconType),
            usecase: .openedObject
        )
        
        applyImageGuideline(model.imageGuideline)
        
        iconImageView.configure(model: model)
        
        iconImageView.isHidden = false
        previewImageView.isHidden = true
        
        activityIndicatorView.hide()
    }
    
    func showImagePreview(image: UIImage?, imageGuideline: ImageGuideline?) {
        applyImageGuideline(imageGuideline)

        previewImageView.image = image

        iconImageView.isHidden = true
        previewImageView.isHidden = false

        activityIndicatorView.show()
    }
    
    func applyImageGuideline(_ imageGuideline: ImageGuideline?) {
        guard let imageGuideline = imageGuideline else {
            containerViewHeightConstraint.constant = 0
            containerViewWidthConstraint.constant = 0
            return
        }
        
        containerViewHeightConstraint.constant = imageGuideline.size.height
        containerViewWidthConstraint.constant = imageGuideline.size.width
        
        containerView.layer.cornerRadius = imageGuideline.cornerRadius
        layer.cornerRadius = imageGuideline.cornerRadius + Constants.borderWidth
    }
    
}

// MARK: - Private extension

private extension ObjectHeaderIconView {
    
    func setupView() {
        previewImageView.contentMode = .scaleAspectFill
        containerView.clipsToBounds = true
        
        iconImageView.isHidden = true
        previewImageView.isHidden = true
        activityIndicatorView.hide()
        
        setupBackgroundColor()
        setupLayout()
    }
    
    func setupBackgroundColor() {
        backgroundColor = .backgroundPrimary
        
        containerView.backgroundColor = .backgroundPrimary
        iconImageView.backgroundColor = .backgroundPrimary
        previewImageView.backgroundColor = .backgroundPrimary
    }
    
    func setupLayout() {
        addSubview(containerView) {
            $0.center(in: self)
            $0.leading.equal(
                to: leadingAnchor,
                constant: Constants.borderWidth
            )
            $0.top.equal(
                to: topAnchor,
                constant: Constants.borderWidth
            )
            
            containerViewHeightConstraint = $0.height.equal(to: 0)
            containerViewWidthConstraint = $0.width.equal(to: 0)
        }
        
        containerView.addSubview(iconImageView) {
            $0.pinToSuperview()
        }
        
        containerView.addSubview(previewImageView) {
            $0.pinToSuperview()
        }
        
        containerView.addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}

extension ObjectHeaderIconView {
    
    enum Constants {
        static let borderWidth: CGFloat = 4
    }
    
}
