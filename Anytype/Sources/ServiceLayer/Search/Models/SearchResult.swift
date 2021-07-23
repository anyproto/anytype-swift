import BlocksModels
import SwiftProtobuf
import ProtobufMessages

struct SearchResult: DetailsDataProtocol {
    let id: BlockId
    let name: String?
    
    let iconEmoji: String?
    let iconImage: String?
    
    let coverId: String?
    let coverType: CoverType?
    let layout: DetailsLayout?
    let alignment: LayoutAlignment?
    
    let isArchived: Bool?
    let done: Bool?
    
    let type: ObjectType?
    
    // Unused
    let creator: BlockId?
    let lastModifiedBy: BlockId?
    
    let featuredRelations: [String]
    
    let lastModifiedDate: Double?
    let createdDate: Double?
    
    init?(fields: Dictionary<String, Google_Protobuf_Value>) {
        guard let id = fields[Relations.id]?.stringValue else {
            return nil
        }
        
        self.id = id
        self.name = fields[Relations.name]?.stringValue
        
        self.iconEmoji = fields[Relations.iconEmoji]?.stringValue
        self.iconImage = fields[Relations.iconImage]?.stringValue
        
        self.coverId = fields[Relations.coverId]?.stringValue
        self.coverType = fields[Relations.coverType].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { CoverType(rawValue: $0) }
        }
        self.layout = fields[Relations.layout].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { DetailsLayout(rawValue: $0) }
        }
        self.alignment = fields[Relations.alignment].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { LayoutAlignment(rawValue: $0) }
        }
        
        self.isArchived = fields[Relations.isArchived]?.boolValue
        self.done = fields[Relations.done]?.boolValue
        
        self.type = fields[Relations.type]?.listValue
            .values.compactMap { rawValue in
                ObjectType(rawValue: rawValue.stringValue)
            }.first
        
        // Unused
        self.lastModifiedBy = fields[Relations.lastModifiedBy]?.stringValue
        self.creator = fields[Relations.creator]?.stringValue
        self.featuredRelations = fields[Relations.featuredRelations]?.listValue.values.map { $0.stringValue } ?? []
        self.createdDate = fields[Relations.createdDate]?.numberValue
        self.lastModifiedDate = fields[Relations.lastModifiedDate]?.numberValue
    }
}
