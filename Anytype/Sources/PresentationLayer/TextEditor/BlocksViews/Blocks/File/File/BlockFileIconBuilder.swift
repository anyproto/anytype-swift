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
    
    private static var dictionary: [UTType: UIImage?] = [
        .text: UIImage.blockFile.content.text,
        .spreadsheet: UIImage.blockFile.content.spreadsheet,
        .presentation: UIImage.blockFile.content.presentation,
        .pdf: UIImage.blockFile.content.pdf,
        .image: UIImage.blockFile.content.image,
        .audio: UIImage.blockFile.content.audio,
        .video: UIImage.blockFile.content.video,
        .archive: UIImage.blockFile.content.archive
    ]

}
