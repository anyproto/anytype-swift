//
//  PlaceholderImageBuilder.swift
//  Anytype
//
//  Created by Konstantin Mordan on 24.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class PlaceholderImageBuilder {

    // MARK: - Private variables
    
    private static var cache = NSCache<NSString, UIImage>()
    
    // MARK: - Internal functions
    
    static func placeholder(with guideline: ImageGuideline, color: UIColor) -> UIImage? {
        let hash = "\(guideline.identifier).\(color.toHexString())"
        
        if let cachedImage = obtainImageFromCache(hash: hash) {
            return cachedImage
        }
        
        let isOpaque = guideline.cornersGuideline.isOpaque
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = isOpaque
        
        let image = UIGraphicsImageRenderer(
            size: guideline.size,
            format: format)
            .image { ctx in
                ctx.cgContext.setFillColor(color.cgColor)
                ctx.fill(ctx.format.bounds)
            }
            .rounded(
                radius: guideline.cornersGuideline.radius,
                opaque: isOpaque,
                backgroundColor: guideline.cornersGuideline.backgroundColor?.cgColor
        )

        saveImageToCache(image, hash: hash)

        return image
    }
    
}

// MARK: - Private extension

private extension PlaceholderImageBuilder {
    
    static func getImageHash(fillColor: UIColor, imageGuideline: ImageGuideline) -> String {
        """
            \(fillColor.toHexString())
            \(imageGuideline.identifier)
        """
    }

    static func obtainImageFromCache(hash: String) -> UIImage? {
        Self.cache.object(forKey: hash as NSString)
    }

    static func saveImageToCache(_ image: UIImage, hash: String) {
        Self.cache.setObject(image, forKey: hash as NSString)
    }
    
}
