import Foundation
import Services

struct DiscussionLocalFile {
    let data: FileData?
    let photosPickerItemHash: Int
}

enum DiscussionLinkedObject: Identifiable {
    case uploadedObject(ObjectDetails)
    case localFile(DiscussionLocalFile)
    
    var id: Int {
        switch self {
        case .uploadedObject(let object):
            return object.id.hashValue
        case .localFile(let file):
            return file.photosPickerItemHash
        }
    }
    
    var uploadedObject: ObjectDetails? {
        switch self {
        case .uploadedObject(let object):
            return object
        case .localFile:
            return nil
        }
    }
    
    var localFile: DiscussionLocalFile? {
        switch self {
        case .uploadedObject:
            return nil
        case .localFile(let file):
            return file
        }
    }
}
