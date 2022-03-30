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
    }
    
    func configure(model: Model) {
        switch model.objectCover {
        case let .cover(cover):
            configureCoverState(cover, model.size)
        case let .preview(previewType):
            configurePreviewState(previewType)
        }
    }
}

private extension ObjectHeaderCoverView {
    
    func configureCoverState(_ cover: DocumentCover, _ size: CGSize) {
        activityIndicatorView.hide()
        
        switch cover {
        case let .imageId(imageId):
            showImageWithId(imageId, size)
        case let .color(color):
            showColor(color, size)
        case let .gradient(gradientColor):
            showGradient(gradientColor, size)
        }
    }
    
    private func showImageWithId(_ imageId: String, _ size: CGSize) {
        let imageGuideline = ImageGuideline(size: size)
        
        imageView.wrapper.imageGuideline(imageGuideline).setImage(id: imageId)
        imageView.contentMode = .scaleAspectFill
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
    
    private func configurePreviewState(_ previewType: ObjectHeaderCoverPreviewType) {
        switch previewType {
        case .remote(let url):
            imageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [.transition(.fade(0.2))]
            )
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
