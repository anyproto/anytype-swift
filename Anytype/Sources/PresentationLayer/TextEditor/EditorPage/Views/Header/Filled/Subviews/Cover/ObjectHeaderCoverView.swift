//
//  ObjectHeaderCoverView.swift
//  ObjectHeaderCoverView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

final class ObjectHeaderCoverView: UIView {
    
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

extension ObjectHeaderCoverView: ConfigurableView {
    
    struct Model {
        let objectCover: ObjectHeaderCoverType
        let size: CGSize
        let fitImage: Bool
    }
    
    func configure(model: Model) {
        imageView.image = nil

        switch model.objectCover {
        case let .cover(cover):
            configureCoverState(cover, model.size, model.fitImage)
        case let .preview(previewType):
            configurePreviewState(previewType, model.size)
        }
    }
}

private extension ObjectHeaderCoverView {
    
    func configureCoverState(_ cover: DocumentCover, _ size: CGSize, _ fitImage: Bool) {
        activityIndicatorView.hide()
        
        switch cover {
        case let .imageId(imageId):
            showImageWithId(imageId, size, fitImage)
        case let .color(color):
            showColor(color, size)
        case let .gradient(gradientColor):
            showGradient(gradientColor, size)
        }
    }
    
    private func showImageWithId(_ imageId: String, _ size: CGSize, _ fitImage: Bool) {
        let imageGuideline = ImageGuideline(size: size)
        
        imageView.wrapper.imageGuideline(imageGuideline).scalingType(nil).setImage(id: imageId)
        imageView.contentMode = fitImage ? .scaleAspectFit : .scaleAspectFill
    }
    
    private func showColor(_ color: UIColor, _ size: CGSize) {
        let imageGuideline = ImageGuideline(size: size)
        let image: UIImage? = ImageBuilder(imageGuideline)
            .setImageColor(color)
            .build()
        imageView.wrapper.setImage(image)
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showGradient(_ gradient: GradientColor, _ size: CGSize) {
        let image: UIImage? = GradientImageBuilder().image(
            size: size,
            color: gradient,
            point: GradientPoint(
                start: CGPoint(x: 0.5, y: 0),
                end: CGPoint(x: 0.5, y: 1)
            )
        )
        imageView.wrapper.setImage(image)
        imageView.contentMode = .scaleToFill
    }
    
    private func configurePreviewState(_ previewType: ObjectHeaderCoverPreviewType, _ size: CGSize) {
        switch previewType {
        case .remote(let url):
            imageView.wrapper
                .imageGuideline(ImageGuideline(size: size))
                .placeholderNeeded(false)
                .setImage(url: url)
        case .image(let image):
            imageView.wrapper.setImage(image)
        }

        imageView.contentMode = .scaleAspectFill

        activityIndicatorView.show()
    }
    
}

// MARK: - Private extension

private extension ObjectHeaderCoverView {
    
    func setupView() {
        setupBackgroundColor()
        
        imageView.clipsToBounds = true
        
        setupLayout()
    }
    
    func setupBackgroundColor() {
        backgroundColor = .Background.primary
        imageView.backgroundColor = .Background.primary
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
