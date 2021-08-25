//
//  ObjectIconImagePainter.swift
//  ObjectIconImagePainter
//
//  Created by Konstantin Mordan on 24.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class ObjectIconImagePainter {
    
    static let shared = ObjectIconImagePainter()
    
    private let cache = NSCache<NSString, UIImage>()
       
}

extension ObjectIconImagePainter: ObjectIconImagePainterProtocol {
    
    func todoImage(isChecked: Bool, imageGuideline: ImageGuideline) -> UIImage {
        let hash = "todo.\(isChecked).\(imageGuideline.identifier)"
        
        if let image = obtainImageFromCache(hash: hash) {
            return image
        }
        
        let image = isChecked ? UIImage.ObjectIcon.checkmark : UIImage.ObjectIcon.checkbox
        
        let modifiedImage = image
            .scaled(to: imageGuideline.size)
            .rounded(
                radius: imageGuideline.cornersGuideline.radius,
                backgroundColor: imageGuideline.cornersGuideline.backgroundColor?.cgColor
            )
        
        saveImageToCache(modifiedImage, hash: hash)
        
        return modifiedImage
    }
    
    func image(with string: String, font: UIFont) -> UIImage? {
        return nil
    }
    
}

private extension ObjectIconImagePainter {
    
    func obtainImageFromCache(hash: String) -> UIImage? {
        cache.object(forKey: hash as NSString)
    }

    func saveImageToCache(_ image: UIImage, hash: String) {
        cache.setObject(image, forKey: hash as NSString)
    }
    
}
