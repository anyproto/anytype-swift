import ProtobufMessages
import BlocksModels

struct ObjectType: Equatable, Hashable {
    let url: String
    let name: String
    let iconEmoji: IconEmoji
    let description: String
    
    let hidden: Bool
    let readonly: Bool
    let isArchived: Bool
    
    let types: [Anytype_Model_SmartBlockType]

//    TODO
//    let relations
//    let layout
    
    static var fallbackType: ObjectType {
        ObjectType(
            url: ObjectTemplateType.note.rawValue,
            name: "Note".localized,
            iconEmoji: .default,
            description: "Blank canvas with no title".localized,
            hidden: false,
            readonly: false,
            isArchived: false,
            types: []
        )
    }
}

extension ObjectType {
    init(model: ProtobufMessages.Anytype_Model_ObjectType) {
        self.init(
            url: model.url,
            name: model.name,
            iconEmoji: IconEmoji(model.iconEmoji) ?? IconEmoji.default,
            description: model.description_p,
            hidden: model.hidden,
            readonly: model.readonly,
            isArchived: model.isArchived,
            types: model.types
        )
    }
}
