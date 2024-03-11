import Foundation
import ProtobufMessages

public struct GalleryManifest {
    public let schema: String
    public let id: String
    public let name: String
    public let author: String
    public let license: String
    public let title: String
    public let description: String
    public let screenshots: [String]
    public let downloadLink: String
    public let fileSize: Int
    public let categories: [String]
    public let language: String
}

extension GalleryManifest {
    init(from model: Anytype_Model_ManifestInfo) {
        self.schema = model.schema
        self.id = model.id
        self.name = model.name
        self.author = model.author
        self.license = model.license
        self.title = model.title
        self.description = model.description_p
        self.screenshots = model.screenshots
        self.downloadLink = model.downloadLink
        self.fileSize = Int(model.fileSize)
        self.categories = model.categories
        self.language = model.language
    }
}
