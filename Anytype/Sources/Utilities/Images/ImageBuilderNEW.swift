//
//  ImageBuilderNEW.swift
//  ImageBuilderNEW
//
//  Created by Konstantin Mordan on 30.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class ImageBuilderNEW {
        
    private let imageStorage: ImageStorageProtocol = ImageStorage.shared
    
    private var imageGuideline: ImageGuideline
    private var imageColor = UIColor.grayscale10
    
    private var text: String?
    private var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    private var textColor = UIColor.grayscaleWhite
    
    init(_ imageGuideline: ImageGuideline) {
        self.imageGuideline = imageGuideline
    }
    
}

extension ImageBuilderNEW: ImageBuilderNEWProtocol {
    
    @discardableResult
    func setImageColor(_ imageColor: UIColor) -> ImageBuilderNEWProtocol {
        self.imageColor = imageColor
        return self
    }
    
    @discardableResult
    func setText(_ text: String) -> ImageBuilderNEWProtocol {
        self.text = text
        return self
    }
    
    @discardableResult
    func setTextColor(_ textColor: UIColor) -> ImageBuilderNEWProtocol {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    func setFont(_ font: UIFont) -> ImageBuilderNEWProtocol {
        self.font = font
        return self
    }
    
    func build() -> UIImage {
        var key = """
        \(ImageBuilderNEW.self).
        \(imageGuideline.identifier).
        \(imageColor.toHexString()).
        """
        if let text = text {
            key.append(text)
            key.append(textColor.toHexString())
            key.append("\(font)")
        }
        
        if let cachedImage = imageStorage.image(forKey: key) {
            return cachedImage
        }
        
        let isOpaque = imageGuideline.cornersGuideline.isOpaque
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = isOpaque
        
        let image = UIGraphicsImageRenderer(
            size: imageGuideline.size,
            format: format)
            .image { ctx in
                ctx.cgContext.setFillColor(imageColor.cgColor)
                ctx.fill(ctx.format.bounds)
                
                text.flatMap {
                   draw(text: $0)
                }
                
            }
            .rounded(
                radius: imageGuideline.cornersGuideline.radius,
                opaque: isOpaque,
                backgroundColor: imageGuideline.cornersGuideline.backgroundColor?.cgColor
        )

        imageStorage.saveImage(image, forKey: key)

        return image
    }
    
    private func draw(text: String) {
        let textSize = NSString(string: text)
            .size(withAttributes: [.font: self.font])
        
        let textRect = CGRect(
            x: 0,
            y: (imageGuideline.size.height - textSize.height) / 2,
            width: imageGuideline.size.width,
            height: textSize.height
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        text.draw(
            with: textRect,
            options: [
                .usesLineFragmentOrigin,
                .usesFontLeading
            ],
            attributes: [
                .foregroundColor: self.textColor,
                .font: self.font,
                .paragraphStyle: paragraphStyle
            ],
            context: nil
        )
    }
    
}
