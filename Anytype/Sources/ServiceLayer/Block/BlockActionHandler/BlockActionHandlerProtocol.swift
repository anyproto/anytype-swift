import Foundation
import BlocksModels

protocol BlockActionHandlerProtocol {

    func handleBlockAction(_ action: BlockHandlerActionType, blockId: BlockId)

    func upload(blockId: BlockId, filePath: String)
    func turnIntoPage(blockId: BlockId) -> BlockId?
    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId?
    func setObjectTypeUrl(_ objectTypeUrl: String)
    func changeCaretPosition(range: NSRange)
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation)
    func changeTextStyle(
        text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange, blockId: BlockId
    )
}
