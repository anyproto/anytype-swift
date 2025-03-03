@testable import Anytype
import Services
import Foundation
import AnytypeCore

final class BlockActionHandlerMock: BlockActionHandlerProtocol {
    var turnIntoStub = false
    var turnIntoNumberOfCalls = 0
    var turnIntoStyleFromLastCall: BlockText.Style?
    func turnInto(_ style: BlockText.Style, blockId: String) {
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
    
    func turnIntoObject(blockId: String) -> String? {
        assertionFailure()
        return nil
    }
    
    func setTextColor(_ color: BlockColor, blockIds: [String]) {
        assertionFailure()
    }

    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [String]) {
        assertionFailure()
    }
    
    func duplicate(blockId: String, spaceId: String) {
        assertionFailure()
    }
    
    func setFields(_ fields: [BlockFields], blockId: String) {
        assertionFailure()
    }
    
    func fetch(url: AnytypeURL, blockId: String) {
        assertionFailure()
    }
    
    func checkbox(selected: Bool, blockId: String) {
        assertionFailure()
    }
    
    func toggle(blockId: String) {
        assertionFailure()
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [String]) {
        assertionFailure()
    }
    
    func setObjectSetType() async throws {
        assertionFailure()
    }
    
    func setObjectCollectionType() async throws {
        assertionFailure()
    }
    
    func applyTemplate(objectId: String, templateId: String) async throws {
        assertionFailure()
    }
    
    func delete(blockIds: [String]) {
        assertionFailure()
    }
    
    func moveToPage(blockId: String, pageId: String) {
        assertionFailure()
    }
    
    func createEmptyBlock(parentId: String, spaceId: String) {
        assertionFailure()
    }
    
    func setLink(url: URL?, range: NSRange, blockId: String) {
        assertionFailure()
    }
    
    func addLink(targetDetails: ObjectDetails, blockId: String) {
        assertionFailure()
    }
    
    func moveToPage(blockIds: [String], pageId: String) async throws {
        assertionFailure()
    }
    
    func addBlock(_ type: BlockContentType, blockId: String, blockText: SafeNSAttributedString?, position: BlockPosition?, spaceId: String) async throws -> String {
        assertionFailure()
        return ""
    }
    
    func toggleWholeBlockMarkup(_ attributedString: SafeNSAttributedString?, markup: MarkupType, info: BlockInformation) -> SafeNSAttributedString? {
        assertionFailure()
        return nil
    }
    
    func upload(blockId: String, filePath: String) {
        assertionFailure()
    }
    
    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> String? {
        assertionFailure()
        return nil
    }
    
    func setObjectType(type: Services.ObjectType) async throws {
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
    
    func changeText(_ text: SafeNSAttributedString, blockId: String) {
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
    
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: String) {
        assertionFailure()
    }
    
    func setTextStyle(_ attribute: MarkupType, range: NSRange, blockId: String, currentText: SafeNSAttributedString, contentType: BlockContentType) async throws -> SafeNSAttributedString {
        fatalError()
    }
    
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: String) {
        assertionFailure()
    }
    
    func uploadFileAt(localPath: String, blockId: String) {
        assertionFailure()
    }
    
    func changeTextForced(_ text: NSAttributedString, blockId: String) {
        assertionFailure()
    }
    
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, currentText: NSAttributedString, info: BlockInformation) {
        assertionFailure()
    }

    func createAndFetchBookmark(targetID: String, position: BlockPosition, url: AnytypeURL) {
        assertionFailure()
    }

    func setFields(_ fields: any FieldsConvertibleProtocol, blockId: String) {
        assertionFailure()
    }

    func setAppearance(blockId: String, appearance: BlockLink.Appearance) {
        assertionFailure()
    }

    func createTable(blockId: String, rowsCount: Int, columnsCount: Int, blockText: SafeNSAttributedString?, spaceId: String) async throws -> String {
        fatalError()
    }
    
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: String) {
        assertionFailure()
    }
    
    func changeMarkup(blockIds: [String], markType: MarkupType) {
        assertionFailure()
    }
    
    func turnIntoBookmark(url: AnytypeURL) async throws -> ObjectType {
        assertionFailure()
        return .emptyType
    }
    
    func pasteContent() {
        assertionFailure()
    }
    
}
