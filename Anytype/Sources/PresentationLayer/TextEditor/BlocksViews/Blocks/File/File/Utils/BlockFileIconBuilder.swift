import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import UniformTypeIdentifiers

struct BlockFileIconBuilder {
    static func convert(mime: String) -> UIImage {
        guard let fileType = UTType.init(mimeType: mime) else {
            return UIImage.blockFile.content.other
        }
        
        return dictionary.first { type, image in
            type == fileType || fileType.isSubtype(of: type)
        }?.value ?? UIImage.blockFile.content.other
    }
    
    private static let dictionary: [UTType: UIImage?] = [
        .text: UIImage.blockFile.content.text,
        .spreadsheet: UIImage.blockFile.content.spreadsheet,
        .presentation: UIImage.blockFile.content.presentation,
        .pdf: UIImage.blockFile.content.pdf,
        .audio: UIImage.blockFile.content.audio,
        
        // Image
        .image: UIImage.blockFile.content.image,
        .ico: UIImage.blockFile.content.image,
        .icns: UIImage.blockFile.content.image,
        .png: UIImage.blockFile.content.image,
        .jpeg: UIImage.blockFile.content.image,
        .webP: UIImage.blockFile.content.image,
        .tiff: UIImage.blockFile.content.image,
        .bmp: UIImage.blockFile.content.image,
        .svg: UIImage.blockFile.content.image,
        .rawImage: UIImage.blockFile.content.image,
        
        // Video
        .movie: UIImage.blockFile.content.video,
        .video: UIImage.blockFile.content.video,
        .quickTimeMovie: UIImage.blockFile.content.video,
        .mpeg: UIImage.blockFile.content.video,
        .mpeg2Video: UIImage.blockFile.content.video,
        .mpeg2TransportStream: UIImage.blockFile.content.video,
        .mpeg4Movie: UIImage.blockFile.content.video,
        .appleProtectedMPEG4Video: UIImage.blockFile.content.video,
        .avi: UIImage.blockFile.content.video,
        
        .archive: UIImage.blockFile.content.archive
    ]

}
