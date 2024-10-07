import Foundation
import UniformTypeIdentifiers

enum DiscussionViewType {
    case image
    case video
    case file
}

extension FileData {
    var discussionViewType: DiscussionViewType {
        if type.conforms(to: .image) {
            return .image
        } else if type.conforms(to: .video) || type.conforms(to: .movie) {
            return .video
        } else {
            return .file
        }
    }
}
