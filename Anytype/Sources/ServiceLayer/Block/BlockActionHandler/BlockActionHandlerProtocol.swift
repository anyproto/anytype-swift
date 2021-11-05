import Foundation
import BlocksModels

protocol BlockActionHandlerProtocol: AnyObject {

    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)

    func upload(blockId: BlockId, filePath: String)
    func turnIntoPage(blockId: BlockId) -> BlockId?
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId?
    func setObjectTypeUrl(_ objectTypeUrl: String)
    func changeCaretPosition(range: NSRange)
    func changeText(_ text: NSAttributedString, info: BlockInformation)
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation)
    func changeTextStyle(
        text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange, blockId: BlockId
    )
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: BlockId)
    func uploadFileAt(localPath: String, blockId: BlockId)
    func onEmptySpotTap()
}
