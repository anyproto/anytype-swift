import Foundation

public struct FileDetails {
    
    public let name: String
    public let fileExt: String
    public let id: String
    public let sizeInBytes: Int
    public let fileMimeType: String
    public let fileContentType: FileContentType
    
    init(objectDetails: ObjectDetails) {
        self.name = objectDetails.name
        self.fileExt = objectDetails.fileExt
        self.id = objectDetails.id
        self.sizeInBytes = objectDetails.sizeInBytes ?? 0
        self.fileMimeType = objectDetails.fileMimeType
        self.fileContentType = objectDetails.layoutValue.fileContentType
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
