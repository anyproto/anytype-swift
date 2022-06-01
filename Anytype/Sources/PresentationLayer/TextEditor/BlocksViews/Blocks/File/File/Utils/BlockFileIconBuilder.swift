import Foundation
import SwiftUI
import Combine
import BlocksModels
import UniformTypeIdentifiers

struct BlockFileIconBuilder {
    
    static func convert(mime: String, fileName: String) -> String {
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
            return Constants.other
        }

        return dictionary.first { type, image in
            type == fileType || fileType.isSubtype(of: type)
        }?.value ?? Constants.other
    }
    
    private static let dictionary: [UTType: String] = [
        .text: Constants.text,
        .plainText: Constants.text,
        .doc: Constants.text,
        .docx: Constants.text,
        .csv: Constants.text,
        .json: Constants.text,

        .spreadsheet: Constants.spreadsheet,
        .xls: Constants.spreadsheet,
        .xlsx: Constants.spreadsheet,

        .presentation: Constants.presentation,
        .pdf: Constants.pdf,

        .audio: Constants.audio,
        .mp3: Constants.audio,
        .mpeg4Audio: Constants.audio,
        .wav: Constants.audio,
        .aiff: Constants.audio,
        .midi: Constants.audio,
        
        // Image
        .image: Constants.image,
        .ico: Constants.image,
        .icns: Constants.image,
        .png: Constants.image,
        .jpeg: Constants.image,
        .webP: Constants.image,
        .tiff: Constants.image,
        .bmp: Constants.image,
        .svg: Constants.image,
        .rawImage: Constants.image,
        
        // Video
        .movie: Constants.video,
        .video: Constants.video,
        .quickTimeMovie: Constants.video,
        .mpeg: Constants.video,
        .mpeg2Video: Constants.video,
        .mpeg2TransportStream: Constants.video,
        .mpeg4Movie: Constants.video,
        .appleProtectedMPEG4Video: Constants.video,
        .avi: Constants.video,
        
        .archive: Constants.archive
    ]
    
    enum Constants {
        static let text = "TextEditor/BlockFile/Content/Text"
        static let spreadsheet = "TextEditor/BlockFile/Content/Spreadsheet"
        static let presentation = "TextEditor/BlockFile/Content/Presentation"
        static let pdf = "TextEditor/BlockFile/Content/PDF"
        static let image = "TextEditor/BlockFile/Content/Image"
        static let audio = "TextEditor/BlockFile/Content/Audio"
        static let video = "TextEditor/BlockFile/Content/Video"
        static let archive = "TextEditor/BlockFile/Content/Archive"
        static let other = "TextEditor/BlockFile/Content/Other"
    }

}
