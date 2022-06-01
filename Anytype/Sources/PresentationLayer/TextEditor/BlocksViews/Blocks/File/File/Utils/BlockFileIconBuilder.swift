import Foundation
import SwiftUI
import Combine
import BlocksModels
import UniformTypeIdentifiers

struct BlockFileIconBuilder {
    static func convert(mime: String, fileName: String) -> UIImage {
        var fileType = UTType(mimeType: mime)
        let isArchive = fileType?.isSubtype(of: .archive) ?? false

        let urlValidFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)

        // Middle can return archive mime type for some files.
        // So we can try to infer mime type from file extension.
        if let urlValidFileName = urlValidFileName,
           let fileExtenstion = URL(string: urlValidFileName)?.pathExtension,
            (fileType.isNil || isArchive)
        {
            fileType = UTType(filenameExtension: fileExtenstion)
        }

        guard let fileType = fileType else {
            return UIImage.blockFile.content.other
        }

        return dictionary.first { type, image in
            type == fileType || fileType.isSubtype(of: type)
        }?.value ?? UIImage.blockFile.content.other
    }
    
    private static let dictionary: [UTType: UIImage?] = [
        .text: UIImage.blockFile.content.text,
        .plainText: UIImage.blockFile.content.text,
        .doc: UIImage.blockFile.content.text,
        .docx: UIImage.blockFile.content.text,
        .csv: UIImage.blockFile.content.text,
        .json: UIImage.blockFile.content.text,

        .spreadsheet: UIImage.blockFile.content.spreadsheet,
        .xls: UIImage.blockFile.content.spreadsheet,
        .xlsx: UIImage.blockFile.content.spreadsheet,

        .presentation: UIImage.blockFile.content.presentation,
        .pdf: UIImage.blockFile.content.pdf,

        .audio: UIImage.blockFile.content.audio,
        .mp3: UIImage.blockFile.content.audio,
        .mpeg4Audio: UIImage.blockFile.content.audio,
        .wav: UIImage.blockFile.content.audio,
        .aiff: UIImage.blockFile.content.audio,
        .midi: UIImage.blockFile.content.audio,
        
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
