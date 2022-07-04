import Foundation
import BlocksModels

extension ObjectType {
    
    public static let fallbackType: ObjectType = ObjectType(
        url: ObjectTypeUrl.bundled(.note).rawValue,
        name: Loc.note,
        iconEmoji: .default,
        description: Loc.ObjectType.fallbackDescription,
        hidden: false,
        readonly: false,
        isArchived: false,
        smartBlockTypes: [.page]
    )
    
}
