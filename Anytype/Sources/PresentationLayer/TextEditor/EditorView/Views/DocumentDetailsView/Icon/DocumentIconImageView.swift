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
    private lazy var imageLoader = ImageLoader(imageView: imageView)
    
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
    
    enum BasicIconModel {
        case imageId(String)
        case preview(UIImage?)
    }
    
    enum ProfileIconModel {
        case imageId(String)
        case placeholder(Character)
        case preview(UIImage?)
    }
    
    enum Model {
        case basic(BasicIconModel)
        case profile(ProfileIconModel)
    }
    
    func configure(model: Model) {
        imageLoader.cleanupSubscription()
        
        switch model {
        case let .basic(basicIcon):
            configureBasicIcon(basicIcon)
        case let .profile(profileIcon):
            configureProfileIcon(profileIcon)
        }
    }
    
    private func configureBasicIcon(_ basicIcon: BasicIconModel) {
        layer.cornerRadius = Constants.basicCornerRadius
        
        switch basicIcon {
        case let .imageId(imageId):
            imageLoader.update(
                imageId: imageId,
                parameters: ImageParameters(width: .thumbnail),
                placeholder: PlaceholderImageBuilder.placeholder(
                    with: ImageGuideline(
                        size: Constants.size,
                        cornerRadius: Constants.basicCornerRadius,
                        backgroundColor: UIColor.grayscaleWhite
                    ),
                    color: UIColor.grayscale10
                )
            )
        case let .preview(image):
            imageView.image = image
        }
    }
    
    private func configureProfileIcon(_ profileIcon: ProfileIconModel) {
        layer.cornerRadius = Constants.profileCornerRadius
        
        switch profileIcon {
        case let .imageId(imageId):
            imageLoader.update(
                imageId: imageId,
                parameters: ImageParameters(width: .thumbnail),
                placeholder: PlaceholderImageBuilder.placeholder(
                    with: ImageGuideline(
                        size: Constants.size,
                        cornerRadius: Constants.profileCornerRadius,
                        backgroundColor: UIColor.grayscaleWhite
                    ),
                    color: UIColor.grayscale10
                )
            )
        case let .placeholder(character):
            imageView.image = PlaceholderImageBuilder.placeholder(
                with: ImageGuideline(
                    size: Constants.size,
                    cornerRadius: Constants.profileCornerRadius,
                    backgroundColor: UIColor.grayscaleWhite
                ),
                color: UIColor.grayscale30,
                textGuideline: PlaceholderImageTextGuideline(text: String(character))
            )
        case let .preview(image):
            imageView.image = image
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
