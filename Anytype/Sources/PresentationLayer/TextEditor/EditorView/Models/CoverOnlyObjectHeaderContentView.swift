//
//  CoverOnlyObjectHeaderContentView.swift
//  CoverOnlyObjectHeaderContentView
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Kingfisher

final class CoverOnlyObjectHeaderContentView: UIView, UIContentView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()

    private let imageView = UIImageView()
        
    // MARK: - Private variables

    private var appliedConfiguration: CoverOnlyObjectHeaderConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? CoverOnlyObjectHeaderConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration: configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: CoverOnlyObjectHeaderConfiguration) {
        super.init(frame: .zero)
        
        setupLayout()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension CoverOnlyObjectHeaderContentView  {
    
    func apply(configuration: CoverOnlyObjectHeaderConfiguration) {
        switch configuration.cover {
        case let .cover(cover):
            configureCoverState(cover)
        case let .preview(image):
            configurePreviewState(image)
        }
        
        appliedConfiguration = configuration
    }
    
    private func configureCoverState(_ cover: DocumentCover) {
        activityIndicatorView.hide()
        
        switch cover {
        case let .imageId(imageId):
            showImageWithId(imageId)
        case let .color(color):
            showImageBasedOnColor(color)
        case let .gradient(startColor, endColor):
            showImageBaseOnGradient(startColor, endColor)
        }
    }
    
    private func showImageWithId(_ imageId: String) {
        let imageGuideline = ImageGuideline(
            size: CGSize(
                width: appliedConfiguration.maxWidth,
                height: Constants.height
            )
        )
        
        let placeholder = PlaceholderImageBuilder.placeholder(
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
            options: [.processor(processor)]
        )
    }
    
    private func showImageBasedOnColor(_ color: UIColor) {
        imageView.image = PlaceholderImageBuilder.placeholder(
            with: ImageGuideline(
                size: CGSize(
                    width: appliedConfiguration.maxWidth,
                    height: Constants.height
                )
            ),
            color: color
        )
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showImageBaseOnGradient(_ startColor: UIColor, _ endColor: UIColor) {
        imageView.image = PlaceholderImageBuilder.gradient(
            size: CGSize(
                width: appliedConfiguration.maxWidth,
                height: Constants.height
            ),
            startColor: startColor,
            endColor: endColor,
            startPoint: CGPoint(x: 0.5, y: 0),
            endPoint: CGPoint(x: 0.5, y: 1)
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

private extension CoverOnlyObjectHeaderContentView {
    
    func setupLayout() {
        layoutUsing.anchors {
            $0.height.equal(to: Constants.height)
        }
        
        addSubview(imageView) {
            $0.pinToSuperview()
        }
        
        addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}

private extension CoverOnlyObjectHeaderContentView {
    
    enum Constants {
        static let height: CGFloat = 224
    }
    
}
