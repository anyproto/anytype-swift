//
//  DocumentIconImageView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Combine

final class DocumentIconImageView: UIView {
    
    // MARK: - Private properties
    
    private let imageView: UIImageView = UIImageView()
    
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

// MARK: - ConfigurableView

extension DocumentIconImageView: ConfigurableView {
    
    enum Model {
        case image(UIImage?)
        case imageId(String)
    }
    
    func configure(model: Model) {
        imageLoader.cleanupSubscription()
        
        switch model {
        case let .image(image):
            imageView.image = image
            
        case let .imageId(imageId):
            imageLoader.update(
                imageId: imageId,
                parameters: ImageParameters(width: .thumbnail),
                placeholder: PlaceholderImageBuilder.placeholder(
                    with: ImageGuideline(
                        size: CGSize(width: 112, height: 112),
                        cornerRadius: Constants.cornerRadius,
                        backgroundColor: UIColor.grayscaleWhite
                    ),
                    color: UIColor.grayscale10
                )
            )
        }
        
    }
    
}

// MARK: - Private extension

private extension DocumentIconImageView {
    
    func setupView() {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        
        // TODO: - load image with size of `ImageView`
        imageView.contentMode = .scaleAspectFill
        
        setUpLayout()
    }
    
    func setUpLayout() {
        addSubview(imageView)
        imageView.pinAllEdges(to: self)
    }
    
}

// MARK: - Constants

private extension DocumentIconImageView {
    
    enum Constants {
        static let cornerRadius: CGFloat = 22
    }
    
}
