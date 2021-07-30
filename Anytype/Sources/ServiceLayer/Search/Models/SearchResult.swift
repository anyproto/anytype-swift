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
        guard let id = fields[DetailsKind.id.rawValue]?.stringValue else {
            return nil
        }
        
        self.id = id
        name = fields[DetailsKind.name.rawValue]?.stringValue
        
        iconEmoji = fields[DetailsKind.iconEmoji.rawValue]?.stringValue
        iconImage = fields[DetailsKind.iconImage.rawValue]?.stringValue
        
        coverId = fields[DetailsKind.coverId.rawValue]?.stringValue
        coverType = fields[DetailsKind.coverType.rawValue].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { CoverType(rawValue: $0) }
        }
        layout = fields[DetailsKind.layout.rawValue].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { DetailsLayout(rawValue: $0) }
        }
        alignment = fields[DetailsKind.alignment.rawValue].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { LayoutAlignment(rawValue: $0) }
        }
        
        isArchived = fields[DetailsKind.isArchived.rawValue]?.boolValue
        done = fields[DetailsKind.done.rawValue]?.boolValue
        
        type = fields[DetailsKind.type.rawValue]?.listValue
            .values.compactMap { rawValue in
                ObjectType(rawValue: rawValue.stringValue)
            }.first
        
        // Unused
        lastModifiedBy = fields[DetailsKind.lastModifiedBy.rawValue]?.stringValue
        creator = fields[DetailsKind.creator.rawValue]?.stringValue
        featuredRelations = fields[DetailsKind.featuredRelations.rawValue]?.listValue.values.map { $0.stringValue } ?? []
        createdDate = fields[DetailsKind.createdDate.rawValue]?.numberValue
        lastModifiedDate = fields[DetailsKind.lastModifiedDate.rawValue]?.numberValue
    }
}
