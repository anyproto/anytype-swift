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

extension BlockInformation {
    public static func createNew(content: BlockContent) -> BlockInformation {
        let alignment: LayoutAlignment = {
            guard case .file(let blockFile) = content else {
                return .left
            }
            
            switch blockFile.contentType {
            case .image : return .center
            default:
                return .left
            }
        }()
        
        return BlockInformation(
            id: BlockId(""),
            content: content,
            backgroundColor: nil,
            alignment: alignment,
            childrenIds: [],
            fields: [:]
        )
    }
    
    public func updated(with backgroundColor: MiddlewareColor?) -> BlockInformation {
        return BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields
        )
    }
    
    public func updated(with fields: BlockFields) -> BlockInformation {
        return BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields
        )
    }
    
    public func updated(with alignment: LayoutAlignment) -> BlockInformation {
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
