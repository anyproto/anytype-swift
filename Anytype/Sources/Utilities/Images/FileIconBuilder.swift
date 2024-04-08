import Foundation
import SwiftUI
import Combine
import Services
import UniformTypeIdentifiers

struct FileIconBuilder {
    
    private typealias FileIconConstants = ImageAsset.FileTypes
    
    static func convert(mime: String, fileName: String) -> ImageAsset {
        var fileType = UTType(mimeType: mime.removing(in: .whitespaces))
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
            return FileIconConstants.other
        }

        return dictionary.first { type, image in
            type == fileType || fileType.isSubtype(of: type)
        }?.value ?? FileIconConstants.other
    }
    
    private static let dictionary: [UTType: ImageAsset] = [
        .text: FileIconConstants.text,
        .plainText: FileIconConstants.text,
        .utf8PlainText: FileIconConstants.text,
        .utf16PlainText: FileIconConstants.text,
        .doc: FileIconConstants.text,
        .docx: FileIconConstants.text,
        .csv: FileIconConstants.text,
        .json: FileIconConstants.text,

        .spreadsheet: FileIconConstants.table,
        .xls: FileIconConstants.table,
        .xlsx: FileIconConstants.table,

        .presentation: FileIconConstants.presentation,
        .pdf: FileIconConstants.pdf,

        .audio: FileIconConstants.audio,
        .mp3: FileIconConstants.audio,
        .mpeg4Audio: FileIconConstants.audio,
        .wav: FileIconConstants.audio,
        .aiff: FileIconConstants.audio,
        .midi: FileIconConstants.audio,
        
        // Image
        .image: FileIconConstants.image,
        .ico: FileIconConstants.image,
        .icns: FileIconConstants.image,
        .png: FileIconConstants.image,
        .jpeg: FileIconConstants.image,
        .webP: FileIconConstants.image,
        .tiff: FileIconConstants.image,
        .bmp: FileIconConstants.image,
        .svg: FileIconConstants.image,
        .rawImage: FileIconConstants.image,
        
        // Video
        .movie: FileIconConstants.video,
        .video: FileIconConstants.video,
        .quickTimeMovie: FileIconConstants.video,
        .mpeg: FileIconConstants.video,
        .mpeg2Video: FileIconConstants.video,
        .mpeg2TransportStream: FileIconConstants.video,
        .mpeg4Movie: FileIconConstants.video,
        .appleProtectedMPEG4Video: FileIconConstants.video,
        .avi: FileIconConstants.video,
        
        .archive: FileIconConstants.archive
    ]
    
}
