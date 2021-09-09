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
        applyImageGuideline(model.imageGuideline)
        
        iconImageView.configure(model: model)
        
        iconImageView.isHidden = false
        previewImageView.isHidden = true
        
        activityIndicatorView.hide()
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
        
        containerView.layer.cornerRadius = imageGuideline.cornersGuideline.radius
        layer.cornerRadius = imageGuideline.cornersGuideline.radius + Constants.borderWidth
    }
    
}

// MARK: - Private extension

private extension NewObjectIconView {
    
    func setupView() {
        containerView.clipsToBounds = true
        
        iconImageView.isHidden = true
        previewImageView.isHidden = true
        activityIndicatorView.hide()
        
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
            $0.center(in: self)
            $0.leading.equal(
                to: self.leadingAnchor,
                constant: Constants.borderWidth
            )
            $0.top.equal(
                to: self.topAnchor,
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

extension NewObjectIconView {
    
    enum Constants {
        static let borderWidth: CGFloat = 4
    }
    
}
