import Foundation
import Services

struct ChatLocalPhotosFile: Equatable {
    let data: FileData?
    let photosPickerItemHash: Int
}

enum ChatLinkedObject: Identifiable, Equatable {
    case uploadedObject(MessageAttachmentDetails)
    case localPhotosFile(ChatLocalPhotosFile)
    case localBinaryFile(FileData)
    case localBookmark(ChatLocalBookmark)
    
    var id: Int {
        switch self {
        case .uploadedObject(let object):
            return object.id.hashValue
        case .localPhotosFile(let file):
            return file.photosPickerItemHash
        case .localBinaryFile(let file):
            return file.path.hashValue
        case .localBookmark(let bookmark):
            return bookmark.hashValue
        }
    }
    
    var uploadedObject: MessageAttachmentDetails? {
        switch self {
        case .uploadedObject(let object):
            return object
        default:
            return nil
        }
    }
    
    var localPhotosFile: ChatLocalPhotosFile? {
        switch self {
        case .localPhotosFile(let file):
            return file
        default:
            return nil
        }
    }
    
    var localBookmark: ChatLocalBookmark? {
        switch self {
        case .localBookmark(let data):
            return data
        default:
            return nil
        }
    }
}
