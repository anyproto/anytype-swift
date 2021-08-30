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
    
    private let imageStorage: ImageStorageProtocol = ImageStorage.shared
       
}

extension ObjectIconImagePainter: ObjectIconImagePainterProtocol {
    
    func todoImage(isChecked: Bool, imageGuideline: ImageGuideline) -> UIImage {
        let hash = "todo.\(isChecked).\(imageGuideline.identifier)"
        
        if let image = imageStorage.image(forKey: hash) {
            return image
        }
        
        let image = isChecked ? UIImage.ObjectIcon.checkmark : UIImage.ObjectIcon.checkbox
        
        let modifiedImage = image
            .scaled(to: imageGuideline.size)
            .rounded(
                radius: imageGuideline.cornersGuideline.radius,
                backgroundColor: imageGuideline.cornersGuideline.backgroundColor?.cgColor
            )
        
        imageStorage.saveImage(modifiedImage, forKey: hash)
        
        return modifiedImage
    }
    
    func image(with string: String,
               font: UIFont,
               textColor: UIColor,
               imageGuideline: ImageGuideline,
               backgroundColor: UIColor) -> UIImage {
        ImageBuilderNEW(imageGuideline)
            .setText(string)
            .setFont(font)
            .setTextColor(textColor)
            .setImageColor(backgroundColor)
            .build()
    }
    
}
