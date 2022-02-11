import ProtobufMessages

public typealias BlockFields = [String : BlockFieldType]

public struct BlockInformation: Hashable {
    public var id: BlockId
    public var content: BlockContent
    
    public var childrenIds: [BlockId]
    
    public let fields: BlockFields
    
    public let backgroundColor: MiddlewareColor?
    public var alignment: LayoutAlignment
    
    public init(
        id: BlockId,
        content: BlockContent,
        backgroundColor: MiddlewareColor?,
        alignment: LayoutAlignment,
        childrenIds: [BlockId],
        fields: BlockFields
    ) {
        self.id = id
        self.content = content
        self.backgroundColor = backgroundColor
        self.alignment = alignment
        self.childrenIds = childrenIds
        self.fields = fields
    }
}

public extension BlockInformation {    
    func updated(with backgroundColor: MiddlewareColor?) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields
        )
    }
    
    func updated(with fields: BlockFields) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields
        )
    }
    
    func updated(with alignment: LayoutAlignment) -> BlockInformation {
        BlockInformation(
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
