//
//  DocumentCoverView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 25.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class DocumentCoverView: UIView {
    
    // MARK: - Internal variables
    
    var onCoverTap: (() -> Void)?
    
    // MARK: - Views
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .grayscale10
        indicator.backgroundColor = UIColor(white: 0.0, alpha: 0.32)
        indicator.isHidden = true
        
        return indicator
    }()

    private let imageView = UIImageView()
    private lazy var imageLoader = ImageLoader().configured(imageView)
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
}

// MARK: - Internal functions

extension DocumentCoverView {
    
    func showLoader() {
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }
    
}

// MARK: - ConfigurableView

extension DocumentCoverView: ConfigurableView {
    
    func configure(model: DocumentCover) {
        hideLoader()
        
        switch model {
        case let .imageId(imageId):
            showImageWithId(imageId)
        case let .color(color):
            showImageBasedOnColor(color)
        case let .gradient(startColor, endColor):
            showImageBaseOnGradient(startColor, endColor)
        }
    }
    
    private func showImageWithId(_ imageId: String) {
        let parameters = ImageParameters(width: .default)
        imageLoader.update(
            imageId: imageId,
            parameters: parameters,
            placeholder: PlaceholderImageBuilder.placeholder(
                with: ImageGuideline(
                    size: CGSize(width: 1, height: Constants.height)
                ),
                color: UIColor.grayscale10
            )
        )
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showImageBasedOnColor(_ color: UIColor) {
        imageView.image = PlaceholderImageBuilder.placeholder(
            with: ImageGuideline(
                size: CGSize(width: 1, height: Constants.height)
            ),
            color: color
        )
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showImageBaseOnGradient(_ startColor: UIColor, _ endColor: UIColor) {
        imageView.image = PlaceholderImageBuilder.gradient(
            size: CGSize(width: 1, height: Constants.height),
            startColor: startColor,
            endColor: endColor,
            startPoint: CGPoint(x: 0.5, y: 0),
            endPoint: CGPoint(x: 0.5, y: 1)
        )
        imageView.contentMode = .scaleToFill
    }
    
    private func hideLoader() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
}

// MARK: - Private extension

private extension DocumentCoverView {
    
    func setupView() {
        imageView.clipsToBounds = true
        
        addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onCoverTap?()
            }
        )
        
        setupLayout()
    }
    
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

private extension DocumentCoverView {
    
    enum Constants {
        static let height: CGFloat = 224
    }
    
}
