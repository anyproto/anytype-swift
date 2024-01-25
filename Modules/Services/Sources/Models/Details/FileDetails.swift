import Foundation

public struct FileDetails {
    
    public var name: String { objectDetails.name }
    public var fileExt: String { objectDetails.fileExt }
    public var id: String { objectDetails.id }
    public var sizeInBytes: Int { objectDetails.sizeInBytes ?? 0 }
    public var fileMimeType: String { objectDetails.fileMimeType }
    public var fileContentType: FileContentType { objectDetails.layoutValue.fileContentType }
    
    private let objectDetails: ObjectDetails
    
    init(objectDetails: ObjectDetails) {
        self.objectDetails = objectDetails
    }
    
    public var fileName: String {
        return fileExt.isNotEmpty ? "\(name).\(fileExt)" : name
    }
}

extension DetailsLayout {
    var fileContentType: FileContentType {
        switch self {
        case .file:
            return .file
        case .image:
            return .image
        case .audio:
            return .audio
        case .video:
            return .video
        default:
            return .none
        }
    }
}
