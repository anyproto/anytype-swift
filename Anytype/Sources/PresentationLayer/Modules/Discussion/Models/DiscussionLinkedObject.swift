import Foundation
import Services

struct DiscussionLocalPhotosFile {
    let data: FileData?
    let photosPickerItemHash: Int
}

enum DiscussionLinkedObject: Identifiable {
    case uploadedObject(MessageAttachmentDetails)
    case localPhotosFile(DiscussionLocalPhotosFile)
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
    
    var localPhotosFile: DiscussionLocalPhotosFile? {
        switch self {
        case .uploadedObject, .localBinaryFile:
            return nil
        case .localPhotosFile(let file):
            return file
        }
    }
}
