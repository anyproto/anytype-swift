import Foundation
import Services

extension ObjectType {
    
    public static let emptyType: ObjectType = ObjectType(
        id: "",
        name: "",
        iconEmoji: .default,
        description: "",
        hidden: false,
        readonly: false,
        isArchived: false,
        isDeleted: false,
        sourceObject: "",
        uniqueKey: nil,
        recommendedRelations: [],
        recommendedLayout: nil
    )
    
}
