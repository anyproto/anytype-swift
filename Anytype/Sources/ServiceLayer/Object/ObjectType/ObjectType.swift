import ProtobufMessages
import BlocksModels
import AnytypeCore

struct ObjectType: Equatable, Hashable {
    let url: String
    let name: String
    let iconEmoji: Emoji
    let description: String
    
    let hidden: Bool
    let readonly: Bool
    let isArchived: Bool
    
    let types: [Anytype_Model_SmartBlockType]
}

extension ObjectType {
    
    static let fallbackType: ObjectType = ObjectType(
        url: ObjectTemplateType.bundled(.note).rawValue,
        name: "Note".localized,
        iconEmoji: .default,
        description: "Blank canvas with no title".localized,
        hidden: false,
        readonly: false,
        isArchived: false,
        types: [.page]
    )
    
}

extension ObjectType {
    init(model: ProtobufMessages.Anytype_Model_ObjectType) {
        self.init(
            url: model.url,
            name: model.name,
            iconEmoji: Emoji(model.iconEmoji) ?? Emoji.default,
            description: model.description_p,
            hidden: model.hidden,
            readonly: model.readonly,
            isArchived: model.isArchived,
            types: model.types
        )
    }
}
