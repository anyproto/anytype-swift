import ProtobufMessages

/// Entity describing some object in Anytype, for example Human, Car, House, Page
struct ObjectTypeData {
    let name: String
    let url: String
    let emoji: String
    let description: String
    
    static func create(objectType: Anytype_Model_ObjectType) -> ObjectTypeData {
        ObjectTypeData(
            name: objectType.name,
            url: objectType.url,
            emoji: objectType.iconEmoji,
            description: objectType.description_p
        )
    }
}
