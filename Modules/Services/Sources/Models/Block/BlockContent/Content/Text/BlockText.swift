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

// MARK: Updates
public extension BlockText {
    func updated(number: Int) -> BlockText {
        BlockText(
            text: text, marks: marks, color: color, contentType: contentType,
            checked: checked, number: number, iconEmoji: iconEmoji, iconImage: iconImage
        )
    }
}

// MARK: Empty
public extension BlockText {
    static func plain(_ text: String, contentType: Style) -> BlockText {
        BlockText(
            text: text, marks: .init(), color: nil, contentType: contentType,
            checked: false, iconEmoji: "", iconImage: ""
        )
    }
    
    static func empty(contentType: Style) -> BlockText {
        BlockText(
            text: "", marks: .init(), color: nil, contentType: contentType,
            checked: false, iconEmoji: "", iconImage: ""
        )
    }
}
