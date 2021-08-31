//
//  DocumentIconImageView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Combine
import Kingfisher

final class DocumentIconImageView: UIView {
        
    // MARK: - Private properties
    
    private let imageView = UIImageView()
    
    private var heightConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    
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
        case basic(BasicIconModel)
        case profile(ProfileIconModel)
    }
    
    enum BasicIconModel {
        case imageId(String)
        case preview(UIImage?)
    }
    
    enum ProfileIconModel {
        case imageId(String)
        case placeholder(Character)
        case preview(UIImage?)
    }
    
    func configure(model: Model) {
        imageView.kf.cancelDownloadTask()
        
        switch model {
        case let .basic(basicIcon):
            configureBasicIcon(basicIcon)
        case let .profile(profileIcon):
            configureProfileIcon(profileIcon)
        }
    }
    
    private func configureBasicIcon(_ basicIcon: BasicIconModel) {
        layer.cornerRadius = Constants.Basic.cornerRadius
        heightConstraint.constant = Constants.Basic.size.height
        widthConstraint.constant = Constants.Basic.size.width
        
        switch basicIcon {
        case let .imageId(imageId):
            downloadImage(
                imageId: imageId,
                imageGuideline: ImageGuideline(
                    size: Constants.Basic.size,
                    cornerRadius: Constants.Basic.cornerRadius,
                    backgroundColor: UIColor.grayscaleWhite
                )
            )
        case let .preview(image):
            imageView.image = image
        }
    }
    
    private func configureProfileIcon(_ profileIcon: ProfileIconModel) {
        layer.cornerRadius = Constants.Profile.cornerRadius
        heightConstraint.constant = Constants.Profile.size.height
        widthConstraint.constant = Constants.Profile.size.width
        
        let imageGuideline = ImageGuideline(
            size: Constants.Profile.size,
            cornerRadius: Constants.Profile.cornerRadius,
            backgroundColor: UIColor.grayscaleWhite
        )
        switch profileIcon {
        case let .imageId(imageId):
            downloadImage(
                imageId: imageId,
                imageGuideline: imageGuideline
            )
        case let .placeholder(character):
            imageView.image = ImageBuilder(imageGuideline)
                .setImageColor(.grayscale30)
                .setText(String(character))
                .setFont(UIFont.bodyRegular.withSize(72))
                .build()
        case let .preview(image):
            imageView.image = image
        }
    }
    
    private func downloadImage(imageId: String, imageGuideline: ImageGuideline) {
        let placeholder = ImageBuilder(imageGuideline).build()
        
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageGuideline.size,
            cornerRadius: .point(imageGuideline.cornersGuideline.radius)
        ).processor
        
        imageView.kf.setImage(
            with: ImageID(id: imageId, width: imageGuideline.size.width).resolvedUrl,
            placeholder: placeholder,
            options: [.processor(processor), .transition(.fade(0.3))]
        )
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
        layoutUsing.anchors {
            heightConstraint = $0.height.equal(to: Constants.Basic.size.height)
            widthConstraint = $0.width.equal(to: Constants.Basic.size.width)
        }
        
        addSubview(imageView) {
            $0.pinToSuperview()
        }
    }
    
}

// MARK: - Constants

extension DocumentIconImageView {
    
    enum Constants {
        enum Basic {
            static let size = CGSize(width: 96, height: 96)
            static let cornerRadius: CGFloat = 4
        }
        
        enum Profile {
            static let size = CGSize(width: 112, height: 112)
            static let cornerRadius: CGFloat = Constants.Profile.size.height / 2
        }
    }
    
}
