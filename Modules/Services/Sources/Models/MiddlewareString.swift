import ProtobufMessages

public struct MiddlewareString {
    public let text: String
    public let marks: Anytype_Model_Block.Content.Text.Marks
    
    public init(text: String, marks: Anytype_Model_Block.Content.Text.Marks = .empty) {
        self.text = text
        self.marks = marks
    }
}

public extension Anytype_Model_Block.Content.Text.Marks {
    static let empty = Anytype_Model_Block.Content.Text.Marks()
}
