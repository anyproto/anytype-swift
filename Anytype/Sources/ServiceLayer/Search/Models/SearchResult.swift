import BlocksModels
import SwiftProtobuf
import ProtobufMessages
import AnytypeCore

struct SearchResult: DetailsDataProtocol {
    let id: BlockId
    let name: String?
    let description: String?
    
    let iconEmoji: String?
    let iconImage: String?
    
    let coverId: String?
    let coverType: CoverType?
    let layout: DetailsLayout?
    let layoutAlign: LayoutAlignment?
    
    let isArchived: Bool?
    let done: Bool?
    
    let type: ObjectType?
    var typeUrl: String? {
        type?.url
    }
    
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
        description = fields[DetailsKind.description.rawValue]?.stringValue
        
        iconEmoji = fields[DetailsKind.iconEmoji.rawValue]?.stringValue
        iconImage = fields[DetailsKind.iconImage.rawValue]?.stringValue
        
        coverId = fields[DetailsKind.coverId.rawValue]?.stringValue
        coverType = fields[DetailsKind.coverType.rawValue].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { CoverType(rawValue: $0) }
        }
        layout = fields[DetailsKind.layout.rawValue].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { DetailsLayout(rawValue: $0) }
        }
        layoutAlign = fields[DetailsKind.layoutAlign.rawValue].flatMap { rawValue in
            rawValue.safeIntValue.flatMap { LayoutAlignment(rawValue: $0) }
        }
        
        isArchived = fields[DetailsKind.isArchived.rawValue]?.boolValue
        done = fields[DetailsKind.done.rawValue]?.boolValue
        
        if let url = fields[DetailsKind.type.rawValue]?.stringValue {
            let type = ObjectTypeProvider.objectType(url: url)
            anytypeAssert(type != nil, "Cannot parse type :\(url))")
            self.type = type
        } else {
            self.type = nil
        }

        // Unused
        lastModifiedBy = fields[DetailsKind.lastModifiedBy.rawValue]?.stringValue
        creator = fields[DetailsKind.creator.rawValue]?.stringValue
        featuredRelations = fields[DetailsKind.featuredRelations.rawValue]?.listValue.values.map { $0.stringValue } ?? []
        createdDate = fields[DetailsKind.createdDate.rawValue]?.numberValue
        lastModifiedDate = fields[DetailsKind.lastModifiedDate.rawValue]?.numberValue
    }
    
}
