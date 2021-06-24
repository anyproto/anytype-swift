import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import UniformTypeIdentifiers

struct BlocksViewsFileMimeConverter {
    private static func isEqualOrSubtype(mime: String, of uttype: UTType) -> Bool {
        guard let type = UTType.init(mimeType: mime) else { return false }
        return type == uttype || type.isSubtype(of: uttype)
    }

    
    private static var dictionary: [UTType: String] = [
        .text: "Text",
        .spreadsheet: "Spreadsheet",
        .presentation: "Presentation",
        .pdf: "PDF",
        .image: "Image",
        .audio: "Audio",
        .video: "Video",
        .archive: "Archive"
    ]
            
    static func convert(mime: String) -> String {
        let key = dictionary.keys.first(where: {self.isEqualOrSubtype(mime: mime, of: $0)})
        let name = key.flatMap({dictionary[$0]}) ?? "Other"
        let path = "TextEditor/Style/File/Content" + "/" + name
        return path
    }
}
