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
    
    private static let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Internal functions
    
    static func placeholder(with guideline: ImageGuideline, color: UIColor) -> UIImage {
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
    
    static func gradient(size: CGSize,
                         startColor: UIColor,
                         endColor: UIColor,
                         startPoint: CGPoint,
                         endPoint: CGPoint) -> UIImage {
        let hash = """
        \(size).
        \(startColor.toHexString()).
        \(endColor.toHexString()).
        \(startPoint.identifier).
        \(endPoint.identifier)
        """
        
        if let cachedImage = obtainImageFromCache(hash: hash) {
            return cachedImage
        }

        let image = UIImage.gradient(
            size: size,
            startColor: startColor,
            endColor: endColor,
            startPoint: startPoint,
            endPoint: endPoint
        )
        
        saveImageToCache(image, hash: hash)
        
        return image
    }
    
}

// MARK: - Private extension

private extension PlaceholderImageBuilder {

    static func obtainImageFromCache(hash: String) -> UIImage? {
        Self.cache.object(forKey: hash as NSString)
    }

    static func saveImageToCache(_ image: UIImage, hash: String) {
        Self.cache.setObject(image, forKey: hash as NSString)
    }
    
}

private extension CGPoint {
    
    var identifier: String {
        NSCoder.string(for: self)
    }
    
}
