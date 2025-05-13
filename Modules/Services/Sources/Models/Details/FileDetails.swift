import Foundation

public struct FileDetails: Sendable {
    
    public let name: String
    public let fileExt: String
    public let id: String
    public let sizeInBytes: Int
    public let fileMimeType: String
    public let fileContentType: FileContentType
    public let type: String
    public let spaceId: String
    
    public init(objectDetails: ObjectDetails) {
        self.name = objectDetails.name
        self.fileExt = objectDetails.fileExt
        self.id = objectDetails.id
        self.sizeInBytes = objectDetails.sizeInBytes ?? 0
        self.fileMimeType = objectDetails.fileMimeType
        self.fileContentType = objectDetails.resolvedLayoutValue.fileContentType
        self.type = objectDetails.type
        self.spaceId = objectDetails.spaceId
    }
    
    public var fileName: String {
        FileDetails.formattedFileName(name, fileExt: fileExt)
    }
    
    public var fileDirectoryName: String {
        let fileName = name.isEmpty ? id : name
        return FileDetails.formattedFileName(fileName, fileExt: fileExt)
    }
    
    static func formattedFileName(_ name: String, fileExt: String) -> String {
        let formattedFileExt = ".\(fileExt)"
        let fileSuffix = fileExt.isNotEmpty && !name.hasSuffix(formattedFileExt) ? formattedFileExt : ""
        let fileName = name + fileSuffix
        return fileName
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
