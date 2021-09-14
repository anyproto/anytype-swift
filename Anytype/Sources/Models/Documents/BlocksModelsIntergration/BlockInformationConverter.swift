import BlocksModels
import ProtobufMessages
import SwiftProtobuf

class BlockInformationConverter {
    static func convert(block: Anytype_Model_Block) -> BlockInformation? {
        guard let content = block.content else {
            return nil
        }
        let blockType = BlocksModelsConverter.convert(middleware: content) ?? .unsupported
        
        let alignment = block.align.asBlockModel ?? .left
        let info =  BlockInformation(
            id: block.id,
            content: blockType,
            backgroundColor: MiddlewareColor(rawValue: block.backgroundColor),
            alignment: alignment,
            childrenIds: block.childrenIds,
            fields: block.fields.toFieldTypeMap()
        )
        
        let validator = BlockValidator(restrictionsFactory: BlockRestrictionsFactory())
        return validator.validated(information: info)
    }
    
    static func convert(information: BlockInformation) -> Anytype_Model_Block? {
        let blockType = information.content
        guard let content = BlocksModelsConverter.convert(block: blockType) else { return nil }

        let id = information.id
        let fields = Google_Protobuf_Struct()
        let restrictions = Anytype_Model_Block.Restrictions()
        let childrenIds = information.childrenIds
        let backgroundColor = information.backgroundColor?.rawValue ?? ""
        let alignment = information.alignment.asMiddleware
        
        return .init(id: id, fields: fields, restrictions: restrictions, childrenIds: childrenIds, backgroundColor: backgroundColor, align: alignment, content: content)
    }
}
