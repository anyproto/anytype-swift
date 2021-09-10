import ProtobufMessages

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
    
    init(model: ProtobufMessages.Anytype_Model_ObjectType) {
        self.url = model.url
        self.name = model.name
        self.iconEmoji = IconEmoji(model.iconEmoji) ?? IconEmoji.default
        self.description = model.description_p
        
        self.hidden = model.hidden
        self.readonly = model.readonly
        self.isArchived = model.isArchived
        
        self.types = model.types
    }
}
