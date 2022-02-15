import ProtobufMessages

public struct BlockText: Hashable {
    public var text: String
    public var marks: Anytype_Model_Block.Content.Text.Marks
    
    /// Block color
    public var color: MiddlewareColor?
    public var contentType: Style
    public var checked: Bool
    public var number: Int
    
    public let iconEmoji: String
    public let iconImage: String
    
    // MARK: - Memberwise initializer
    public init(
        text: String,
        marks: Anytype_Model_Block.Content.Text.Marks,
        color: MiddlewareColor?,
        contentType: Style,
        checked: Bool,
        number: Int = 1,
        iconEmoji: String,
        iconImage: String
    ) {
        self.text = text
        self.marks = marks
        self.color = color
        self.contentType = contentType
        self.checked = checked
        self.number = number
        self.iconEmoji = iconEmoji
        self.iconImage = iconImage
    }
}

// MARK: ContentType / Text / Supplements
public extension BlockText {
    init(contentType: Style) {
        self.init(
            text: "", marks: .init(), color: nil,
            contentType: contentType, checked: false, iconEmoji: "", iconImage: ""
        )
    }
            
    // MARK: - Create

    static var empty: Self {
        .init(
            text: "", marks: .init(), color: nil,
            contentType: .text, checked: false, iconEmoji: "", iconImage: ""
        )
    }
    
    func updated(number: Int) -> BlockText {
        BlockText(
            text: text, marks: marks, color: color, contentType: contentType,
            checked: checked, number: number, iconEmoji: iconEmoji, iconImage: iconImage
        )
    }
}
