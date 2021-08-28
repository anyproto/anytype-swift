//
//  ObjectCoverView.swift
//  ObjectCoverView
//
//  Created by Konstantin Mordan on 11.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

final class ObjectCoverView: UIView {
    
    // MARK: - Views
    
    private let imageView = UIImageView()
    
    private let activityIndicatorView = ActivityIndicatorView()
    private let tapGesture = BindableGestureRecognizer()
    
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

    struct Model {
        let cover: ObjectCover
        let maxWidth: CGFloat
    }
    
    func configure(model: Model) {
        tapGesture.action = model.cover.onTap
        
        switch model.cover.state {
        case let .cover(cover):
            configureCoverState(
                cover: cover,
                maxWidth: model.maxWidth
            )
        case let .preview(image):
            configurePreviewState(image)
        }
    }
    
    private func configureCoverState(cover: DocumentCover, maxWidth: CGFloat) {
        activityIndicatorView.hide()
        
        switch cover {
        case let .imageId(imageId):
            showImageWithId(imageId, maxWidth: maxWidth)
        case let .color(color):
            showImageBasedOnColor(color, maxWidth: maxWidth)
        case let .gradient(startColor, endColor):
            showImageBaseOnGradient(startColor, endColor, maxWidth: maxWidth)
        }
    }
    
    private func showImageWithId(_ imageId: String, maxWidth: CGFloat) {
        let imageGuideline = ImageGuideline(
            size: CGSize(
                width: maxWidth,
                height: Constants.coverHeight
            )
        )
        
        let placeholder = ImageBuilder.placeholder(
            with: imageGuideline,
            color: UIColor.grayscale10
        )
        
        let processor = ResizingImageProcessor(
            referenceSize: imageGuideline.size,
            mode: .aspectFill
        )
        |> CroppingImageProcessor(size: imageGuideline.size)
        
        imageView.kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: imageId, width: .default)),
            placeholder: placeholder,
            options: [.processor(processor), .transition(.fade(0.3))]
        )
    }
    
    private func showImageBasedOnColor(_ color: UIColor, maxWidth: CGFloat) {
        imageView.image = ImageBuilder.placeholder(
            with: ImageGuideline(
                size: CGSize(
                    width: maxWidth,
                    height: Constants.coverHeight
                )
            ),
            color: color
        )
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showImageBaseOnGradient(_ startColor: UIColor, _ endColor: UIColor, maxWidth: CGFloat) {
        imageView.image = GradientImageBuilder().image(
            size: CGSize(
                width: maxWidth,
                height: Constants.coverHeight
            ),
            color: GradientColor(
                start: startColor,
                end: endColor
            ),
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
        imageView.clipsToBounds = true
        addGestureRecognizer(tapGesture)
        
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(imageView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: Constants.coverHeight)
            $0.bottom.equal(to: bottomAnchor, constant: -Constants.bottomInset)
        }
        imageView.addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}

extension ObjectCoverView {
    
    enum Constants {
        static let coverHeight: CGFloat = 232
        static let bottomInset: CGFloat = 32
    }
    
}
