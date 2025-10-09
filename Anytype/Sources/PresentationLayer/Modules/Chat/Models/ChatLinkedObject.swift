import Foundation
import Services

struct ChatLocalPhotosFile: Equatable {
    var data: ChatLocalBinaryFile?
    let photosPickerItemHash: Int
}

struct ChatLocalBinaryFile: Equatable {
    let data: FileData
    var preloadFileId: String?
}

enum ChatLinkedObject: Identifiable, Equatable {
    case uploadedObject(MessageAttachmentDetails)
    case localPhotosFile(ChatLocalPhotosFile)
    case localBinaryFile(ChatLocalBinaryFile)
    case localBookmark(ChatLocalBookmark)
    
    var id: Int {
        switch self {
        case .uploadedObject(let object):
            return object.id.hashValue
        case .localPhotosFile(let file):
            return file.photosPickerItemHash
        case .localBinaryFile(let file):
            return file.data.path.hashValue
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

    var preloadFileId: String? {
        switch self {
        case .localPhotosFile(let file):
            return file.data?.preloadFileId
        case .localBinaryFile(let file):
            return file.preloadFileId
        default:
            return nil
        }
    }
    
    var fileData: FileData? {
        switch self {
        case .localPhotosFile(let file):
            return file.data?.data
        case .localBinaryFile(let file):
            return file.data
        case .localBookmark, .uploadedObject:
            return nil
        }
        
    }
}
