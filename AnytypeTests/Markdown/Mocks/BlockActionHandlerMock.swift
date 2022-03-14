@testable import Anytype
import BlocksModels

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
    
    func setTextColor(_ color: BlockColor, blockId: BlockId) {
        assertionFailure()
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockId: BlockId) {
        assertionFailure()
    }
    
    func duplicate(blockId: BlockId) {
        assertionFailure()
    }
    
    func setFields(_ fields: [Anytype.BlockFields], blockId: BlockId) {
        assertionFailure()
    }
    
    func fetch(url: URL, blockId: BlockId) {
        assertionFailure()
    }
    
    func checkbox(selected: Bool, blockId: BlockId) {
        assertionFailure()
    }
    
    func toggle(blockId: BlockId) {
        assertionFailure()
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockId: BlockId) {
        assertionFailure()
    }
    
    func delete(blockId: BlockId) {
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
    
    func addLink(targetId: BlockId, blockId: BlockId) {
        assertionFailure()
    }
    
    func addBlock(_ type: BlockContentType, blockId: BlockId) {
        assertionFailure()
    }
    
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: BlockId) {
        assertionFailure()
    }
    
    func upload(blockId: BlockId, filePath: String) {
        assertionFailure()
    }
    
    func createPage(targetId: BlockId, type: ObjectTemplateType) -> BlockId? {
        assertionFailure()
        return nil
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
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
    
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: BlockId) {
        assertionFailure()
    }
    
    func uploadFileAt(localPath: String, blockId: BlockId) {
        assertionFailure()
    }
    
    func changeTextForced(_ text: NSAttributedString, blockId: BlockId) {
        assertionFailure()
    }
    
    func handleKeyboardAction(_ action: CustomTextView.KeyboardAction, info: BlockInformation, newString attributedText: NSAttributedString) {
        assertionFailure()
    }

    func createAndFetchBookmark(targetID: BlockId, position: BlockPosition, url: String) {
        assertionFailure()
    }
    
    func past(blockId: BlockId, range: NSRange) {
        assertionFailure()
    }
}
