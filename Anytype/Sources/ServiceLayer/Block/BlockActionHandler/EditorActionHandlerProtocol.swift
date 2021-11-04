import Foundation
import BlocksModels

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()
    
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: BlockId)
    func uploadFileAt(localPath: String, blockId: BlockId)
        
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId?
    func showPage(blockId: BlockId)
    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)
    
    func setObjectTypeUrl(_ objectTypeUrl: String)
    func showLinkToSearch(blockId: BlockId, attrText: NSAttributedString, range: NSRange)
    
    func changeCarretPosition(range: NSRange)
    
    func changeText(_ text: NSAttributedString, info: BlockInformation)
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation)
    func changeTextStyle(
        text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange, blockId: BlockId
    )
}
