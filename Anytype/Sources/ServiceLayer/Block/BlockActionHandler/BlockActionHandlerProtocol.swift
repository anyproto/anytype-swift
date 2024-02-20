import Foundation
import Services
import AnytypeCore

protocol BlockSelectionHandler: AnyObject {
    func didSelectEditingState(info: BlockInformation)
    func didSelectStyleSelection(infos: [BlockInformation])
}

protocol BlockActionHandlerProtocol: AnyObject {
    var blockSelectionHandler: BlockSelectionHandler? { get set }

    func turnInto(_ style: BlockText.Style, blockId: String)
    @discardableResult
    func turnIntoPage(blockId: String) async throws -> String?
    
    func setTextColor(_ color: BlockColor, blockIds: [String])
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [String])
    func duplicate(blockId: String)
    func fetch(url: AnytypeURL, blockId: String) async throws
    func checkbox(selected: Bool, blockId: String)
    func toggle(blockId: String)
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [String])
    func delete(blockIds: [String])
    func moveToPage(blockId: String, pageId: String)
    func createEmptyBlock(parentId: String)
    func setLink(url: URL?, range: NSRange, blockId: String)
    func setLinkToObject(linkBlockId: String?, range: NSRange, blockId: String)
    func addLink(targetDetails: ObjectDetails, blockId: String)
    func changeMarkup(blockIds: [String], markType: MarkupType)
    func addBlock(_ type: BlockContentType, blockId: String, blockText: NSAttributedString?, position: BlockPosition?)
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: String)
    func upload(blockId: String, filePath: String) async throws
    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> String?

    func setObjectType(type: ObjectType) async throws
    func setObjectSetType() async throws
    func setObjectCollectionType() async throws
    func applyTemplate(objectId: String, templateId: String) async throws
    func changeTextForced(_ text: NSAttributedString, blockId: String)
    func changeText(_ text: NSAttributedString, info: BlockInformation)
    func handleKeyboardAction(
        _ action: CustomTextView.KeyboardAction,
        currentText: NSAttributedString,
        info: BlockInformation
    )
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: String)
    func setTextStyle(_ attribute: MarkupType, range: NSRange, blockId: String, currentText: NSAttributedString?)
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: String)
    func uploadFileAt(localPath: String, blockId: String)
    func selectBlock(info: BlockInformation)
    func createAndFetchBookmark(
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    ) async throws
    func setAppearance(blockId: String, appearance: BlockLink.Appearance)
    func createTable(
        blockId: String,
        rowsCount: Int,
        columnsCount: Int,
        blockText: SafeSendable<NSAttributedString?>
    ) async throws -> String
}

extension BlockActionHandlerProtocol {
    func addBlock(_ type: BlockContentType, blockId: String, blockText: NSAttributedString? = nil) {
        addBlock(type, blockId: blockId, blockText: blockText, position: nil)
    }
}
