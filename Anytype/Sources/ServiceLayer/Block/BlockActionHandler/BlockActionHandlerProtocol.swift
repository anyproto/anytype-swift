import Foundation
import Services
import AnytypeCore

protocol BlockSelectionHandler: AnyObject {
    func didSelectEditingState(info: BlockInformation)
    func didSelectStyleSelection(infos: [BlockInformation])
}

protocol BlockActionHandlerProtocol: AnyObject {
    var blockSelectionHandler: BlockSelectionHandler? { get set }

    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    @discardableResult
    func turnIntoPage(blockId: BlockId) async throws -> BlockId?
    
    func setTextColor(_ color: BlockColor, blockIds: [BlockId])
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [BlockId])
    func duplicate(blockId: BlockId)
    func fetch(url: AnytypeURL, blockId: BlockId) async throws
    func checkbox(selected: Bool, blockId: BlockId)
    func toggle(blockId: BlockId)
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [BlockId])
    func delete(blockIds: [BlockId])
    func moveToPage(blockId: BlockId, pageId: BlockId)
    func createEmptyBlock(parentId: BlockId)
    func setLink(url: URL?, range: NSRange, blockId: BlockId)
    func setLinkToObject(linkBlockId: BlockId?, range: NSRange, blockId: BlockId)
    func addLink(targetId: BlockId, typeId: String, blockId: BlockId)
    func changeMarkup(blockIds: [BlockId], markType: MarkupType)
    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString?, position: BlockPosition?)
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: BlockId)
    func upload(blockId: BlockId, filePath: String) async throws
    func createPage(targetId: BlockId, type: ObjectTypeId) async throws -> BlockId?

    func setObjectTypeId(_ objectTypeId: String) async throws
    func setObjectSetType() async throws
    func setObjectCollectionType() async throws
    func changeTextForced(_ text: NSAttributedString, blockId: BlockId)
    func changeText(_ text: NSAttributedString, info: BlockInformation)
    func handleKeyboardAction(
        _ action: CustomTextView.KeyboardAction,
        currentText: NSAttributedString,
        info: BlockInformation
    )
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId)
    func setTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId, currentText: NSAttributedString?)
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: BlockId)
    func uploadFileAt(localPath: String, blockId: BlockId)
    func selectBlock(info: BlockInformation)
    func createAndFetchBookmark(
        targetID: BlockId,
        position: BlockPosition,
        url: AnytypeURL
    ) async throws
    func setAppearance(blockId: BlockId, appearance: BlockLink.Appearance)
    func createTable(
        blockId: BlockId,
        rowsCount: Int,
        columnsCount: Int,
        blockText: SafeSendable<NSAttributedString?>
    ) async throws -> BlockId
}

extension BlockActionHandlerProtocol {
    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString? = nil) {
        addBlock(type, blockId: blockId, blockText: blockText, position: nil)
    }
}
