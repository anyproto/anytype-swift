//
//  ObjectCoverView.swift
//  ObjectCoverView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

final class ObjectCoverView: UIView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()
    private let imageView = UIImageView()
    
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

extension ObjectCoverView: ConfigurableView {
    
    func configure(model: ObjectCover) {
        switch model {
        case let .cover(cover):
            configureCoverState(cover)
        case let .preview(image):
            configurePreviewState(image)
        }
    }
    
}

private extension ObjectCoverView {
    
    func configureCoverState(_ cover: DocumentCover) {
        activityIndicatorView.hide()
        
        switch cover {
        case let .imageId(imageId):
            showImageWithId(imageId)
        case let .color(color):
            showColor(color)
        case let .gradient(startColor, endColor):
            showGradient(
                GradientColor(start: startColor, end: endColor)
            )
        }
    }
    
    private func showImageWithId(_ imageId: String) {
        let imageGuideline = ImageGuideline(
            size: CGSize(
                width: bounds.width,
                height: bounds.height
            )
        )
        
        let placeholder = ImageBuilder(imageGuideline).build()
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageGuideline.size,
            cornerRadius: nil
        ).processor
        
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(
            with: ImageID(id: imageId, width: imageGuideline.size.width.asImageWidth).resolvedUrl,
            placeholder: placeholder,
            options: [.processor(processor), .transition(.fade(0.2))]
        )
        
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showColor(_ color: UIColor) {
        let imageGuideline = ImageGuideline(
            size: CGSize(
                width: bounds.width,
                height: bounds.height
            )
        )
        
        imageView.image = ImageBuilder(imageGuideline)
            .setImageColor(color)
            .build()
        
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showGradient(_ gradient: GradientColor) {
        imageView.image = GradientImageBuilder().image(
            size: CGSize(
                width: bounds.width,
                height: bounds.height
            ),
            color: gradient,
            point: GradientPoint(
                start: CGPoint(x: 0.5, y: 0),
                end: CGPoint(x: 0.5, y: 1)
            )
        )
        imageView.contentMode = .scaleToFill
    }
    
    private func configurePreviewState(_ image: UIImage?) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.show()
    }
    
}

// MARK: - Private extension

private extension ObjectCoverView {
    
    func setupView() {
        setupBackgroundColor()
        
        imageView.clipsToBounds = true
        
        setupLayout()
    }
    
    func setupBackgroundColor() {
        backgroundColor = .backgroundPrimary
        imageView.backgroundColor = .backgroundPrimary
    }
    
    func setupLayout() {
        addSubview(imageView) {
            $0.pinToSuperview()
        }
        
        addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}
