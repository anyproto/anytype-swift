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

// MARK: - Internal functions

extension DocumentIconImageView {
    
    func showLoaderWithImage(at path: String?) {
        imageView.image = path.flatMap { UIImage(contentsOfFile: $0) }
        imageView.addDimmedOverlay()
        
        let indicator = UIActivityIndicatorView()
        indicator.color = .grayscaleWhite
        addSubview(indicator)
        indicator.layoutUsing.anchors {
            $0.center(in: self)
        }
        
        indicator.startAnimating()
    }
    
}

// MARK: - ConfigurableView

extension DocumentIconImageView: ConfigurableView {
    
    func configure(model: String) {
        imageView.removeAllSubviews()
        
        let parameters = ImageParameters(width: .thumbnail)
        
        imageLoader.update(imageId: model, parameters: parameters)
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
