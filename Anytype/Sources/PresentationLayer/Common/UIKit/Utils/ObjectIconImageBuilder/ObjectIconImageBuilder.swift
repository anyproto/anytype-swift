//
//  ObjectIconImageBuilder.swift
//  ObjectIconImageBuilder
//
//  Created by Konstantin Mordan on 19.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

final class ObjectIconImageBuilder {
    
    private let kingfisherManager = KingfisherManager.shared
    
}

extension ObjectIconImageBuilder: ObjectIconImageBuilderProtocol {
    
    func iconImage(from iconType: DocumentIconType,
                   size: ObjectIconImageSize,
                   onCompletion: @escaping (UIImage?) -> Void) {
        switch iconType {
        case .basic(let basic):
            basicIconImage(basicIcon: basic, size: size, onCompletion: onCompletion)
        case .profile(let profile):
            profileIconImage(profileIcon: profile, size: size, onCompletion: onCompletion)
        case let .emoji(emoji):
            let image = PlaceholderImageBuilder.placeholder(
                with: size.emoji,
                color: UIColor.grayscale10,
                textGuideline: PlaceholderImageTextGuideline(
                    text: emoji.value,
                    font: .systemFont(ofSize: 48)
                )
            )
            
            onCompletion(image)
        }
    }
    
}

private extension ObjectIconImageBuilder {
    
    func basicIconImage(basicIcon: DocumentIconType.Basic,
                        size: ObjectIconImageSize,
                        onCompletion: @escaping (UIImage?) -> Void) {
        switch basicIcon {
        case let .imageId(imageId):
            downloadImage(
                imageId: imageId,
                imageGuideline: size.basic,
                onCompletion: onCompletion
            )
        }
    }
    
    func profileIconImage(profileIcon: DocumentIconType.Profile,
                          size: ObjectIconImageSize,
                          onCompletion: @escaping (UIImage?) -> Void) {
        switch profileIcon {
        case let .imageId(imageId):
            downloadImage(
                imageId: imageId,
                imageGuideline: size.profile,
                onCompletion: onCompletion
            )
        case let .placeholder(character):
            let image = PlaceholderImageBuilder.placeholder(
                with: size.profile,
                color: UIColor.grayscale30,
                textGuideline: PlaceholderImageTextGuideline(text: String(character))
            )
            
            onCompletion(image)
        }
    }
    
    func downloadImage(imageId: String,
                       imageGuideline: ImageGuideline,
                       onCompletion: @escaping (UIImage?) -> Void) {
        guard
            let url = UrlResolver.resolvedUrl(.image(id: imageId, width: .default))
        else {
            onCompletion(nil)
            return
        }
        
        let processor = ResizingImageProcessor(
            referenceSize: imageGuideline.size,
            mode: .aspectFill
        )
        |> CroppingImageProcessor(size: imageGuideline.size)
        |> RoundCornerImageProcessor(
            radius: .point(imageGuideline.cornersGuideline.radius)
        )
        
        kingfisherManager.retrieveImage(
            with: url,
            options: [.processor(processor)]
        ) { result in
            guard case let .success(result) = result else { return }
            
            onCompletion(result.image)
        }
    }
    
}
