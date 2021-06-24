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
    
    var supportedTypeIdentifiers: [String] {
        switch self {
        case .images:
            return [
                UTType.image,
                UTType.ico,
                UTType.icns,
                UTType.png,
                UTType.jpeg,
                UTType.webP,
                UTType.tiff,
                UTType.bmp,
                UTType.svg,
                UTType.rawImage
            ].map { $0.identifier }
        case .videos:
            return [
                UTType.movie,
                UTType.video,
                UTType.quickTimeMovie,
                UTType.mpeg,
                UTType.mpeg2Video,
                UTType.mpeg2TransportStream,
                UTType.mpeg4Movie,
                UTType.appleProtectedMPEG4Video,
                UTType.avi
            ].map { $0.identifier }
        }
    }
    
}
