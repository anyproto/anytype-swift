//
//  MediaPickerContentType.swift
//  Anytype
//
//  Created by Kovalev Alexander on 30.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import PhotosUI

/// Content type to display in picker from gallery
///
/// - images: Images
/// - videos: Videos
enum MediaPickerContentType {
    case images
    case videos
    
    /// Filter for system picker
    var filter: PHPickerFilter {
        switch self {
        case .images:
            return .images
        case .videos:
            return .videos
        }
    }
    
    var typeIdentifier: String {
        switch self {
        case .images:
            return UTType.image.identifier
        case .videos:
            return UTType.quickTimeMovie.identifier
        }
    }
    
}
