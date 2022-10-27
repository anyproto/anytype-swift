import Foundation
import BlocksModels
import AnytypeCore

protocol BlockSelectionHandler: AnyObject {
    func didSelectEditingState(info: BlockInformation)
    func didSelectStyleSelection(info: BlockInformation)
}

protocol BlockActionHandlerProtocol: AnyObject {
    var blockSelectionHandler: BlockSelectionHandler? { get set }

    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    @discardableResult
    func turnIntoPage(blockId: BlockId) -> BlockId?
    
    func setTextColor(_ color: BlockColor, blockIds: [BlockId])
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [BlockId])
    func duplicate(blockId: BlockId)
    func setFields(_ fields: FieldsConvertibleProtocol, blockId: BlockId)
    func fetch(url: AnytypeURL, blockId: BlockId)
    func checkbox(selected: Bool, blockId: BlockId)
    func toggle(blockId: BlockId)
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [BlockId])
    func delete(blockIds: [BlockId])
    func moveToPage(blockId: BlockId, pageId: BlockId)
    func createEmptyBlock(parentId: BlockId)
    func setLink(url: URL?, range: NSRange, blockId: BlockId)
    func setLinkToObject(linkBlockId: BlockId?, range: NSRange, blockId: BlockId)
    func addLink(targetId: BlockId, typeUrl: String, blockId: BlockId)
    func changeMarkup(blockIds: [BlockId], markType: MarkupType)
    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString?, position: BlockPosition?)
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: BlockId)
    func upload(blockId: BlockId, filePath: String)
    func createPage(targetId: BlockId, type: ObjectTypeUrl) -> BlockId?

    func setObjectTypeUrl(_ objectTypeUrl: String)
    func setObjectSetType() -> BlockId

    func changeTextForced(_ text: NSAttributedString, blockId: BlockId)
    func changeText(_ text: NSAttributedString, info: BlockInformation)
    func handleKeyboardAction(
        _ action: CustomTextView.KeyboardAction,
        currentText: NSAttributedString,
        info: BlockInformation
    )
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId)
    func setTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId, currentText: NSAttributedString?)
    func uploadMediaFile(uploadingSource: MediaFileUploadingSource, type: MediaPickerContentType, blockId: BlockId)
    func uploadFileAt(localPath: String, blockId: BlockId)
    func selectBlock(info: BlockInformation)
    func createAndFetchBookmark(
        targetID: BlockId,
        position: BlockPosition,
        url: AnytypeURL
    )
    func setAppearance(blockId: BlockId, appearance: BlockLink.Appearance)
    func createTable(
        blockId: BlockId,
        rowsCount: Int,
        columnsCount: Int,
        blockText: NSAttributedString?
    )
}

extension BlockActionHandlerProtocol {
    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString? = nil) {
        addBlock(type, blockId: blockId, blockText: blockText, position: nil)
    }
}
