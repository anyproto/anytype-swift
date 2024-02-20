import Foundation
import Services
import AnytypeCore

protocol BlockActionHandlerProtocol: AnyObject {
    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    @discardableResult
    func turnIntoPage(blockId: String) async throws -> String?
    
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
    func addLink(targetDetails: ObjectDetails, blockId: BlockId)
    func changeMarkup(blockIds: [BlockId], markType: MarkupType)
    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString?, position: BlockPosition?)
    func toggleWholeBlockMarkup(
        _ attributedString: NSAttributedString?,
        markup: MarkupType,
        info: BlockInformation
    ) -> NSAttributedString?
    func upload(blockId: BlockId, filePath: String) async throws
    func createPage(targetId: BlockId, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> BlockId?

    func setObjectType(type: ObjectType) async throws
    func setObjectSetType() async throws
    func setObjectCollectionType() async throws
    func applyTemplate(objectId: String, templateId: String) async throws
    func changeText(_ text: NSAttributedString, blockId: BlockId)
    func setTextStyle(
        _ attribute: MarkupType,
        range: NSRange,
        blockId: BlockId,
        currentText: NSAttributedString?,
        contentType: BlockContentType
    )
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: BlockId)
    func uploadFileAt(localPath: String, blockId: BlockId)
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
