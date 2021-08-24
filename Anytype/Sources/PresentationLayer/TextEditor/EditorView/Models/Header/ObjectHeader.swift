//
//  ObjectHeader.swift
//  ObjectHeader
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case iconOnly(ObjectIcon)
    case coverOnly(ObjectCover)
    case iconAndCover(ObjectIcon, ObjectCover)
    case empty
    
}

extension ObjectHeader: ContentConfigurationProvider {
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case let .iconOnly(objectIcon):
            return ObjectHeaderIconOnlyConfiguration(icon: objectIcon)
            
        case let .coverOnly(objectCover):
            return ObjectHeaderCoverOnlyConfiguration(
                cover: objectCover,
                maxWidth: maxWidth
            )
            
        case let .iconAndCover(objectIcon, objectCover):
            return ObjectHeaderIconAndCoverConfiguration(
                icon: objectIcon,
                cover: objectCover,
                maxWidth: maxWidth
            )
        case .empty:
            return ObjectHeaderEmptyConfiguration()
        }
    }
    
}

extension ObjectHeader {
    
    func modifiedByLocalEvent(_ event: ObjectHeaderLocalEvent) -> ObjectHeader? {
        switch event {
        case .iconUploading(let uIImage):
            return modifiedByIconUploadingEventWith(image: uIImage)
        case .coverUploading(let uIImage):
            return modifiedByCoverUploadingEventWith(image: uIImage)
        }
    }
    
    private func modifiedByIconUploadingEventWith(image: UIImage) -> ObjectHeader? {
        switch self {
        case .iconOnly(let objectIcon):
            return .iconOnly(modifiedObjectIcon(objectIcon, image))
        case .coverOnly(let objectCover):
            return .iconAndCover(.preview(.basic(image), .left), objectCover)
        case .iconAndCover(let objectIcon, let objectCover):
            return .iconAndCover(modifiedObjectIcon(objectIcon, image), objectCover)
        case .empty:
            return .iconOnly(.preview(.profile(image), .left))
        }
    }
    
    private func modifiedObjectIcon(_ objectIcon: ObjectIcon, _ image: UIImage) -> ObjectIcon {
        switch objectIcon {
        case .icon(let documentIconType, let layoutAlignment):
            switch documentIconType {
            case .basic:
                return .preview(.basic(image), layoutAlignment)
            case .profile:
                return .preview(.profile(image), layoutAlignment)
            }
        case .preview(let objectIconPreviewType, let layoutAlignment):
            switch objectIconPreviewType {
            case .basic:
                return .preview(.basic(image), layoutAlignment)
            case .profile:
                return .preview(.profile(image), layoutAlignment)
            }
        }
    }
    
    private func modifiedByCoverUploadingEventWith(image: UIImage) -> ObjectHeader? {
        switch self {
        case .iconOnly(let objectIcon):
            return .iconAndCover(objectIcon, .preview(image))
        case .coverOnly:
            return .coverOnly(.preview(image))
        case .iconAndCover(let objectIcon, _):
            return .iconAndCover(objectIcon, .preview(image))
        case .empty:
            return .coverOnly(.preview(image))
        }
    }
    
}
