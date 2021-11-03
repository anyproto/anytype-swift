import Foundation
import BlocksModels

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()
    
    func uploadMediaFile(
        itemProvider: NSItemProvider,
        type: MediaPickerContentType,
        blockId: ActionHandlerBlockIdSource
    )
    func uploadFileAt(localPath: String, blockId: ActionHandlerBlockIdSource)
        
    func turnIntoPage(blockId: ActionHandlerBlockIdSource) -> BlockId?
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId?
    func showPage(blockId: ActionHandlerBlockIdSource)
    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
    
    func setObjectTypeUrl(_ objectTypeUrl: String)
    func showLinkToSearch(blockId: BlockId, attrText: NSAttributedString, range: NSRange)
    
    func changeCarretPosition(range: NSRange)
    
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation)
    func changeTextStyle(
        text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange, blockId: BlockId
    )
}
