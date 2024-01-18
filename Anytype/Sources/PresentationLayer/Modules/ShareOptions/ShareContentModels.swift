import Foundation
import Services

struct ShareContentCounter {
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

enum SharedSaveOptions {
    case newObject(spaceId: String, linkToObject: ObjectDetails?)
    case blocks(spaceId: String, addToObject: ObjectDetails)
}

enum ShareSaveAsType {
    case newObject
    case block
    
    var supportedLayouts: [DetailsLayout] {
        switch self {
        case .newObject:
            return DetailsLayout.editorLayouts + [.collection]
        case .block:
            return DetailsLayout.editorLayouts
        }
    }
}
