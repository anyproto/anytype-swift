import Foundation

struct ShareContentCounter {
    var textCount: Int
    var bookmarksCount: Int
    var filesCount: Int
    
    var onlyText: Bool {
        bookmarksCount == 0 && filesCount == 0
    }
    
    var onlyBookmarks: Bool {
        textCount == 0 && filesCount == 0
    }
    
    var onlyFiles: Bool {
        textCount == 0 && bookmarksCount == 0
    }
}

enum SharedSaveOptions {
    case newObject(spaceId: String, linkToObjectId: String?)
    case blocks(spaceId: String, addToObjectId: String)
}

enum ShareSaveAsType {
    case newObject
    case block
}
