import BlocksModels
import ProtobufMessages
import SwiftProtobuf

class BlockModelsInformationConverter {
    static func convert(block: Anytype_Model_Block) -> BlockInformation? {
        guard let content = block.content, let blockType = BlocksModelsConverter.convert(middleware: content) else { return nil }
        
        var information = TopLevelBlockBuilder.shared.informationBuilder.build(id: block.id, content: blockType)

        // TODO: Add fields and restrictions.
        // Add parsers for them and model.
        // "Add fields and restrictions into our model."
        information.childrenIds = block.childrenIds
        information.backgroundColor = block.backgroundColor
        if let alignment = BlocksModelsParserCommonAlignmentConverter.asModel(block.align) {
            information.alignment = alignment
        }
        return information
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
