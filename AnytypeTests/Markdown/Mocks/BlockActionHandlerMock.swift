@testable import Anytype
import Services
import Foundation
import AnytypeCore

final class BlockActionHandlerMock: BlockActionHandlerProtocol {
    var blockSelectionHandler: BlockSelectionHandler? {
        get {
            assertionFailure()
            return nil
        }
        set {
            assertionFailure()
        }
    }
    
    var turnIntoStub = false
    var turnIntoNumberOfCalls = 0
    var turnIntoStyleFromLastCall: BlockText.Style?
    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        if turnIntoStub {
            turnIntoNumberOfCalls += 1
            turnIntoStyleFromLastCall = style
        } else {
            assertionFailure()
        }
    }
    
    func selectBlock(info: BlockInformation) {
        assertionFailure()
    }
    
    func turnIntoPage(blockId: BlockId) -> BlockId? {
        assertionFailure()
        return nil
    }
    
    func setTextColor(_ color: BlockColor, blockIds: [BlockId]) {
        assertionFailure()
    }

    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [BlockId]) {
        assertionFailure()
    }
    
    func duplicate(blockId: BlockId) {
        assertionFailure()
    }
    
    func setFields(_ fields: [BlockFields], blockId: BlockId) {
        assertionFailure()
    }
    
    func fetch(url: AnytypeURL, blockId: BlockId) {
        assertionFailure()
    }
    
    func checkbox(selected: Bool, blockId: BlockId) {
        assertionFailure()
    }
    
    func toggle(blockId: BlockId) {
        assertionFailure()
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [BlockId]) {
        assertionFailure()
    }
    
    func setObjectSetType() async throws {
        assertionFailure()
    }
    
    func setObjectCollectionType() async throws {
        assertionFailure()
    }
    
    func delete(blockIds: [BlockId]) {
        assertionFailure()
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        assertionFailure()
    }
    
    func createEmptyBlock(parentId: BlockId) {
        assertionFailure()
    }
    
    func setLink(url: URL?, range: NSRange, blockId: BlockId) {
        assertionFailure()
    }
    
    func setLinkToObject(linkBlockId: BlockId?, range: NSRange, blockId: BlockId) {
        assertionFailure()
    }
    
    func addLink(targetId: BlockId, typeId: String, blockId: BlockId) {
        assertionFailure()
    }
    
    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString?, position: BlockPosition?) {
        assertionFailure()
    }
    
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: BlockId) {
        assertionFailure()
    }
    
    func upload(blockId: BlockId, filePath: String) {
        assertionFailure()
    }
    
    func createPage(targetId: BlockId, type: ObjectTypeId) -> BlockId? {
        assertionFailure()
        return nil
    }
    
    func setObjectTypeId(_ objectTypeId: String) {
        assertionFailure()
    }
    
    var changeCaretPositionStub = false
    var changeCaretPositionLastRange: NSRange?
    var changeCaretPositionNumberOfCalls = 0
    func changeCaretPosition(range: NSRange) {
        if changeCaretPositionStub {
            changeCaretPositionLastRange = range
            changeCaretPositionNumberOfCalls += 1
        } else {
            assertionFailure()
        }
    }
    
    func changeText(_ text: NSAttributedString, blockId: BlockId) {
        assertionFailure()
    }
    
    var changeTextStub = false
    var changeTextNumberOfCalls = 0
    var changeTextTextFromLastCall: NSAttributedString?
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        if changeTextStub {
            changeTextNumberOfCalls += 1
            changeTextTextFromLastCall = text
        } else {
            assertionFailure()
        }
    }
    
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation) {
        assertionFailure()
    }
    
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId) {
        assertionFailure()
    }
    
    func setTextStyle(_ attribute: Anytype.MarkupType, range: NSRange, blockId: Services.BlockId, currentText: NSAttributedString?) {
        assertionFailure()
    }
    
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: BlockId) {
        assertionFailure()
    }
    
    func uploadFileAt(localPath: String, blockId: BlockId) {
        assertionFailure()
    }
    
    func changeTextForced(_ text: NSAttributedString, blockId: BlockId) {
        assertionFailure()
    }
    
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, currentText: NSAttributedString, info: BlockInformation) {
        assertionFailure()
    }

    func createAndFetchBookmark(targetID: BlockId, position: BlockPosition, url: AnytypeURL) {
        assertionFailure()
    }

    func setFields(_ fields: FieldsConvertibleProtocol, blockId: BlockId) {
        assertionFailure()
    }

    func setAppearance(blockId: BlockId, appearance: BlockLink.Appearance) {
        assertionFailure()
    }

    func createTable(blockId: Services.BlockId, rowsCount: Int, columnsCount: Int, blockText: AnytypeCore.SafeSendable<NSAttributedString?>) async throws -> Services.BlockId {
        fatalError()
    }
    
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: BlockId) {
        assertionFailure()
    }
    
    func changeMarkup(blockIds: [Services.BlockId], markType: Anytype.MarkupType) {
        assertionFailure()
    }
}
