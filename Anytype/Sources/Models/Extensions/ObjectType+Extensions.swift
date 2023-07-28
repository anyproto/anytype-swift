import Foundation
import Services

extension ObjectType {
    
    public static let fallbackType: ObjectType = ObjectType(
        id: ObjectTypeId.bundled(.note).rawValue,
        name: Loc.note,
        iconEmoji: .default,
        description: Loc.ObjectType.fallbackDescription,
        hidden: false,
        readonly: false,
        isArchived: false,
        isDeleted: false,
        sourceObject: "",
        recommendedRelations: [],
        recommendedLayout: nil
    )
    
}
