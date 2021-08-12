import ProtobufMessages

struct MiddlewareTuple: Hashable {
    var attribute: Anytype_Model_Block.Content.Text.Mark.TypeEnum
    var value: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(attribute)
        hasher.combine(value)
    }
}
