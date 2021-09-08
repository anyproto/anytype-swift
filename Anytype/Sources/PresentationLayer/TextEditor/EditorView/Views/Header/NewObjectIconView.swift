//
//  NewObjectIconView.swift
//  NewObjectIconView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class NewObjectIconView: UIView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()
        
    private let containerView = UIView()
    
    private let iconImageView = ObjectIconImageView()
    private var iconImageViewHeightConstraint: NSLayoutConstraint!
    private var iconImageViewWidthConstraint: NSLayoutConstraint!
    
    private let previewImageView = UIImageView()
    private var previewImageViewHeightConstraint: NSLayoutConstraint!
    private var previewImageViewWidthConstraint: NSLayoutConstraint!
    
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

extension NewObjectIconView: ConfigurableView {

    enum Model {
        case iconImageModel(ObjectIconImageView.Model)
        case preview(ObjectIconPreviewType)
    }
    
    func configure(model: Model) {
        switch model {
        case .iconImageModel(let model):
            showIconImageModel(model)
        case .preview(let preview):
            showPreviewImageType(preview)
        }
    }
    
}

private extension NewObjectIconView {
        
    func showIconImageModel(_ model: ObjectIconImageView.Model) {
        guard let imageGuideline = model.imageGuideline else {
            setIconImageSizeConstraintsActive(false)
            setPreviewImageSizeConstraintsActive(false)
            return
        }
        
        iconImageViewHeightConstraint.constant = imageGuideline.size.height
        iconImageViewWidthConstraint.constant = imageGuideline.size.width
        
        containerView.layer.cornerRadius = imageGuideline.cornersGuideline.radius
        layer.cornerRadius = imageGuideline.cornersGuideline.radius + Constants.borderWidth
        
        setIconImageSizeConstraintsActive(true)
        setPreviewImageSizeConstraintsActive(false)
        
        iconImageView.configure(model: model)
        
        iconImageView.isHidden = false
        previewImageView.isHidden = true
    }
    
    func showPreviewImageType(_ type: ObjectIconPreviewType) {
        var imageGuideline: ImageGuideline?
        var image: UIImage?
        
        switch type {
        case .basic(let uIImage):
            imageGuideline = ObjectIconImageUsecase.openedObject.objectIconImageGuidelineSet.basicImageGuideline
            image = uIImage
        case .profile(let uIImage):
            imageGuideline = ObjectIconImageUsecase.openedObject.objectIconImageGuidelineSet.profileImageGuideline
            image = uIImage
        }
        
        guard let imageGuideline = imageGuideline else {
            setIconImageSizeConstraintsActive(false)
            setPreviewImageSizeConstraintsActive(false)
            return
        }
        
        previewImageViewHeightConstraint.constant = imageGuideline.size.height
        previewImageViewWidthConstraint.constant = imageGuideline.size.width
        
        containerView.layer.cornerRadius = imageGuideline.cornersGuideline.radius
        layer.cornerRadius = imageGuideline.cornersGuideline.radius + Constants.borderWidth
        
        setIconImageSizeConstraintsActive(false)
        setPreviewImageSizeConstraintsActive(true)
        
        previewImageView.image = image
        
        iconImageView.isHidden = true
        previewImageView.isHidden = false
    }
    
    func setIconImageSizeConstraintsActive(_ isActive: Bool) {
        iconImageViewHeightConstraint.isActive = isActive
        iconImageViewWidthConstraint.isActive = isActive
    }
    
    func setPreviewImageSizeConstraintsActive(_ isActive: Bool) {
        previewImageViewHeightConstraint.isActive = isActive
        previewImageViewWidthConstraint.isActive = isActive
    }
}

// MARK: - Private extension

private extension NewObjectIconView {
    
    func setupView() {
        containerView.clipsToBounds = true
        setupBackgroundColor()
        setupLayout()
    }
    
    func setupBackgroundColor() {
        backgroundColor = .grayscaleWhite
        
        containerView.backgroundColor = .grayscaleWhite
        iconImageView.backgroundColor = .grayscaleWhite
        previewImageView.backgroundColor = .grayscaleWhite
    }
    
    func setupLayout() {
        addSubview(containerView) {
            $0.center(in: containerView)
            $0.leading.equal(
                to: self.leadingAnchor,
                constant: Constants.borderWidth
            )
            $0.top.equal(
                to: self.topAnchor,
                constant: Constants.borderWidth
            )
        }
        
        containerView.addSubview(iconImageView) {
            iconImageViewHeightConstraint = $0.height.equal(to: 0, activate: false)
            iconImageViewWidthConstraint = $0.width.equal(to: 0, activate: false)
            $0.pinToSuperview()
        }
        
        containerView.addSubview(previewImageView) {
            previewImageViewHeightConstraint = $0.height.equal(to: 0, activate: false)
            previewImageViewWidthConstraint = $0.width.equal(to: 0, activate: false)
            $0.pinToSuperview()
        }
        
        containerView.addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}

extension NewObjectIconView {
    
    enum Constants {
        static let borderWidth: CGFloat = 4
    }
    
}
