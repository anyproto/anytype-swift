import BlocksModels
import ProtobufMessages
import SwiftProtobuf

enum BlockInformationConverter {
    
    static func convert(block: Anytype_Model_Block) -> BlockInformation? {
        guard let content = block.content else {
            return nil
        }
                
        let blockContent = BlocksModelsConverter.convert(middleware: content) ?? .unsupported
        let alignment = block.align.asBlockModel ?? .left
        let color = MiddlewareColor(rawValue: block.backgroundColor)
        let info =  BlockInformation(
            id: block.id,
            content: blockContent,
            backgroundColor: MiddlewareColor(rawValue: block.backgroundColor),
            alignment: alignment,
            childrenIds: block.childrenIds,
            configurationData: .init(
                backgroundColor: color,
                indentationStyle: .none,
                calloutBackgroundColor: nil
            ),
            fields: block.fields.fields
        )
        
        return BlockValidator().validated(information: info)
    }
    
    static func convert(information: BlockInformation) -> Anytype_Model_Block? {
        let blockContent = information.content
        guard let content = BlocksModelsConverter.convert(block: blockContent) else { return nil }

        let id = information.id
        let fields = Google_Protobuf_Struct()
        let restrictions = Anytype_Model_Block.Restrictions()
        let childrenIds = information.childrenIds
        let backgroundColor = information.backgroundColor?.rawValue ?? ""
        let alignment = information.alignment.asMiddleware
        
        
        return Anytype_Model_Block(
            id: id,
            fields: fields,
            restrictions: restrictions,
            childrenIds: childrenIds,
            backgroundColor: backgroundColor,
            align: alignment,
            verticalAlign: .middle,
            content: content
        )
    }
}
