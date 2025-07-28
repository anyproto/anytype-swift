import Foundation
import Services
import AnytypeCore

struct ShareLegacyContentCounter {
    var textCount: Int
    var bookmarksCount: Int
    var filesCount: Int
    
    var onlyText: Bool {
        textCount > 0 && bookmarksCount == 0 && filesCount == 0
    }
    
    var onlyBookmarks: Bool {
        textCount == 0 && bookmarksCount > 0 && filesCount == 0
    }
    
    var onlyFiles: Bool {
        textCount == 0 && bookmarksCount == 0 && filesCount > 0
    }
}

enum SharedLegacySaveOptions {
    case container(spaceId: String, linkToObject: ObjectDetails?)
    case newObject(spaceId: String, linkToObject: ObjectDetails?)
    case blocks(spaceId: String, addToObject: ObjectDetails)
}

enum ShareLegacySaveAsType {
    case container
    case object
    case block
    
    var supportedLayouts: [DetailsLayout] {
        switch self {
        case .object, .container:
            return DetailsLayout.editorLayouts + [.collection]
        case .block:
            return DetailsLayout.editorLayouts
        }
    }
}
