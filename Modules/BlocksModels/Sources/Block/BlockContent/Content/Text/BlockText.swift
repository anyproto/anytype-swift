import ProtobufMessages

public struct BlockText: Hashable {
    public var text: String
    public var marks: Anytype_Model_Block.Content.Text.Marks
    
    /// Block color
    public var color: MiddlewareColor?
    public var contentType: Style
    public var checked: Bool
    public var number: Int
    
    // MARK: - Memberwise initializer
    public init(
        text: String,
        marks: Anytype_Model_Block.Content.Text.Marks,
        color: MiddlewareColor?,
        contentType: Style,
        checked: Bool,
        number: Int = 1
    ) {
        self.text = text
        self.marks = marks
        self.color = color
        self.contentType = contentType
        self.checked = checked
        self.number = number
    }
}

// MARK: ContentType / Text / Supplements
public extension BlockText {
    init(contentType: Style) {
        self.init(text: "", marks: .init(), color: nil, contentType: contentType, checked: false)
    }
            
    // MARK: - Create

    static var empty: Self {
        .init(text: "", marks: .init(), color: nil, contentType: .text, checked: false)
    }
    
    func updated(number: Int) -> BlockText {
        BlockText(text: text, marks: marks, color: color, contentType: contentType, checked: checked, number: number)
    }
}
