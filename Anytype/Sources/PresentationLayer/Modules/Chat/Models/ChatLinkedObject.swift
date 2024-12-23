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
    
    var id: Int {
        switch self {
        case .uploadedObject(let object):
            return object.id.hashValue
        case .localPhotosFile(let file):
            return file.photosPickerItemHash
        case .localBinaryFile(let file):
            return file.path.hashValue
        }
    }
    
    var uploadedObject: MessageAttachmentDetails? {
        switch self {
        case .uploadedObject(let object):
            return object
        case .localPhotosFile, .localBinaryFile:
            return nil
        }
    }
    
    var localPhotosFile: ChatLocalPhotosFile? {
        switch self {
        case .uploadedObject, .localBinaryFile:
            return nil
        case .localPhotosFile(let file):
            return file
        }
    }
}
