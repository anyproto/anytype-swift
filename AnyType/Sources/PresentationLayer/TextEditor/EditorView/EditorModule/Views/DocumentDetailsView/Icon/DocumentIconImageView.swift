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
    
    private var menuInteractionHandler: IconMenuInteractionHandler?
    
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
    
    enum State {
        case `default`(imageId: String)
        case imageUploading(imagePath: String)
    }
    
    func configure(model: State) {
        switch model {
        case let .default(imageId: imageId):
            showImageWithId(imageId)
        case let .imageUploading(imagePath: imagePath):
            showLoaderWithImage(at: imagePath)
        }
        
    }
    
    private func showImageWithId(_ imageId: String) {
        imageView.removeAllSubviews()
        
        let parameters = ImageParameters(width: .thumbnail)
        imageLoader.update(
            imageId: imageId,
            parameters: parameters,
            placeholder: PlaceholderImageBuilder.placeholder(
                with: ImageGuideline(
                    size: Constants.size,
                    cornerRadius: Constants.cornerRadius,
                    backgroundColor: UIColor.grayscaleWhite
                ),
                color: UIColor.grayscale10
            )
        )
    }
    
    private func showLoaderWithImage(at path: String) {
        imageView.image = UIImage(contentsOfFile: path)
        
        imageView.addDimmedOverlay()
        imageView.addActivityIndicatorView(with: .grayscale10)
    }
    
}

// MARK: - IconMenuInteractableView

extension DocumentIconImageView: IconMenuInteractableView {
    
    func enableMenuInteraction(with onUserAction: @escaping (DocumentIconViewUserAction) -> Void) {
        let handler = IconMenuInteractionHandler(
            targetView: self,
            onUserAction: onUserAction
        )
        
        let interaction = UIContextMenuInteraction(delegate: handler)
        addInteraction(interaction)
        
        menuInteractionHandler = handler
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

        layoutUsing.anchors {
            $0.size(Constants.size)
        }
    }
    
}

// MARK: - Constants

private extension DocumentIconImageView {
    
    enum Constants {
        static let cornerRadius: CGFloat = 22
        static let size = CGSize(width: 112, height: 112)
    }
    
}
