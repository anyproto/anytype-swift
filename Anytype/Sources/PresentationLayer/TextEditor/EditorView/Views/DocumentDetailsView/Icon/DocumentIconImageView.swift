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
    
    let height: CGFloat
    
    // MARK: - Private properties
    
    private let imageView: UIImageView = UIImageView()
    private lazy var imageLoader = ImageLoader().configured(imageView)
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        self.height = Constants.size.height
        
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.height = Constants.size.height
        
        super.init(coder: coder)
        
        setupView()
    }
    
}

// MARK: - ConfigurableView

extension DocumentIconImageView: ConfigurableView {
    
    struct Model {
        let content: Content
        let isProfileLayout: Bool
    }
    
    enum Content {
        case image(UIImage?)
        case imageId(String)
        case placeholder(Character)
    }
    
    func configure(model: Model) {
        imageLoader.cleanupSubscription()
        
        switch model.content {
        case let .image(image):
            imageView.image = image
            
        case let .imageId(imageId):
            imageLoader.update(
                imageId: imageId,
                parameters: ImageParameters(width: .thumbnail),
                placeholder: PlaceholderImageBuilder.placeholder(
                    with: ImageGuideline(
                        size: Constants.size,
                        cornerRadius: cornerRadius(isProfileLayout: model.isProfileLayout),
                        backgroundColor: UIColor.grayscaleWhite
                    ),
                    color: UIColor.grayscale10
                )
            )
            
        case let .placeholder(character):
            imageView.image = PlaceholderImageBuilder.placeholder(
                with: ImageGuideline(
                    size: Constants.size,
                    cornerRadius: cornerRadius(isProfileLayout: model.isProfileLayout),
                    backgroundColor: UIColor.grayscaleWhite
                ),
                color: UIColor.grayscale10,
                textGuideline: PlaceholderImageTextGuideline(text: String(character))
            )
        }
        
        layer.cornerRadius = cornerRadius(isProfileLayout: model.isProfileLayout)
    }
    
    func cornerRadius(isProfileLayout: Bool) -> CGFloat {
        if isProfileLayout {
            return Constants.profileCornerRadius
        } else {
            return Constants.basicCornerRadius
        }
    }
    
}

// MARK: - Private extension

private extension DocumentIconImageView {
    
    func setupView() {
        clipsToBounds = true
        
        // TODO: - load image with size of `ImageView`
        imageView.contentMode = .scaleAspectFill
        
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(imageView) {
            $0.pinToSuperview()
            $0.size(Constants.size)
        }
    }
    
}

// MARK: - Constants

private extension DocumentIconImageView {
    
    enum Constants {
        static let basicCornerRadius: CGFloat = 22
        static let profileCornerRadius: CGFloat = Constants.size.height / 2
        static let size = CGSize(width: 122, height: 122)
    }
    
}
