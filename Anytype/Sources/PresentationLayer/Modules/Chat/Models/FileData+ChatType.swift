import Foundation
import UniformTypeIdentifiers

enum ChatViewType {
    case image
    case video
    case file
}

extension FileData {
    var chatViewType: ChatViewType {
        if type.conforms(to: .image) {
            return .image
        } else if type.conforms(to: .video) || type.conforms(to: .movie) {
            return .video
        } else {
            return .file
        }
    }
}
