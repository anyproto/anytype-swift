import ProtobufMessages

public struct BlockInformation: Hashable {
    public var id: BlockId
    public var content: BlockContent
    
    public var childrenIds: [BlockId]
    
    public var fields: [String: BlockFieldType]
    
    public let backgroundColor: String
    public var alignment: LayoutAlignment
    
    public init(
        id: BlockId,
        content: BlockContent,
        backgroundColor: String,
        alignment: LayoutAlignment,
        childrenIds: [BlockId],
        fields: [String: BlockFieldType]
    ) {
        self.id = id
        self.content = content
        self.backgroundColor = backgroundColor
        self.alignment = alignment
        self.childrenIds = childrenIds
        self.fields = fields
    }

    // TODO: Remove, used for collection view diff
    public static func == (lhs: BlockInformation, rhs: BlockInformation) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension BlockInformation {
    public static func createNew(content: BlockContent) -> BlockInformation {
        return BlockInformation(
            id: BlockId(""),
            content: content,
            backgroundColor: "",
            alignment: .left,
            childrenIds: [],
            fields: [:]
        )
    }
    
    public func updated(with backgroundColor: String) -> BlockInformation {
        return BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields
        )
    }
}

public enum FieldName {
    public static let codeLanguage = "lang"
}
