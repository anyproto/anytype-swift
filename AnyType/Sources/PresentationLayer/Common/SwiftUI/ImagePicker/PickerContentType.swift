//
//  PickerContentType.swift
//  AnyType
//
//  Created by Kovalev Alexander on 30.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import PhotosUI

/// Content type to display in picker from gallery
///
/// - images: Images
/// - videos: Videos
enum PickerContentType {
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
}
