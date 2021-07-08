import BlocksModels
import ProtobufMessages
import SwiftProtobuf

class BlockModelsInformationConverter {
    static func convert(block: Anytype_Model_Block) -> BlockInformation? {
        guard let content = block.content, let blockType = BlocksModelsConverter.convert(middleware: content) else {
            return nil
        }
        
        let alignment = BlocksModelsParserCommonAlignmentConverter.asModel(block.align) ?? .left
        return BlockInformation(
            id: block.id,
            content: blockType,
            backgroundColor: block.backgroundColor,
            alignment: alignment,
            childrenIds: block.childrenIds,
            fields: [:]
        )
    }
    
    static func convert(information: BlockInformation) -> Anytype_Model_Block? {
        let blockType = information.content
        guard let content = BlocksModelsConverter.convert(block: blockType) else { return nil }

        let id = information.id
        let fields = Google_Protobuf_Struct()
        let restrictions = Anytype_Model_Block.Restrictions()
        let childrenIds = information.childrenIds
        let backgroundColor = information.backgroundColor
        
        var alignment: Anytype_Model_Block.Align = .left
        if let value = BlocksModelsParserCommonAlignmentConverter.asMiddleware(information.alignment) {
            alignment = value
        }

        return .init(id: id, fields: fields, restrictions: restrictions, childrenIds: childrenIds, backgroundColor: backgroundColor, align: alignment, content: content)
    }
}
