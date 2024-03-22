import ProtobufMessages

struct MiddlewareString: Hashable, Equatable {
    let text: String
    let marks: Anytype_Model_Block.Content.Text.Marks
    
    init(text: String, marks: Anytype_Model_Block.Content.Text.Marks = .empty) {
        self.text = text
        self.marks = marks
    }
}

private extension Anytype_Model_Block.Content.Text.Marks {
    static let empty = Anytype_Model_Block.Content.Text.Marks()
}
