//
//  AnytypeImageViewWrapper.swift
//  Anytype
//
//  Created by Konstantin Mordan on 30.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    
    var wrapper: AnytypeImageViewWrapper {
        AnytypeImageViewWrapper(imageView: self)
    }
    
}

final class AnytypeImageViewWrapper {
    
    private var imageGuideline: ImageGuideline?
    
    private let imageView: UIImageView
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
}

extension AnytypeImageViewWrapper {
    
    @discardableResult
    func imageGuideline(_ imageGuideline: ImageGuideline) -> AnytypeImageViewWrapper {
        self.imageGuideline = imageGuideline
        return self
    }
    
    func setImage(id: String) {
        guard id.isNotEmpty else {
            // TODO: assert
            return
        }
        
        guard let imageGuideline = imageGuideline else {
            // TODO: assert
            return
        }
        
        guard
            let url = ImageMetadata(id: id, width: imageGuideline.size.width.asImageWidth).contentUrl
        else {
            // TODO: assert
            return
        }
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(with: url, placeholder: nil, options: []) { result in
            // TODO: assert
        }
    }
    
}
