import Testing
import Combine
import UIKit
import Services
@testable import Anytype

// Pins the identity-rebind contract on the view model itself: `rowIdentity` (and with it the
// diffable identifier) survives rebind(to:) while `info` follows the replacing block, and the
// undo rebind resets the handler's completed fork. Without these, reverting `hashable` to the
// block id — or dropping the fork reset — would pass every other test.
@MainActor
struct TextBlockViewModelRebindTests {

    @Test func rowIdentitySurvivesRebindWhileInfoFollows() {
        let handler = TextBlockActionHandlerStub()
        let model = makeModel(blockId: "old", handler: handler)
        let identifierBeforeRebind = model.hashable

        model.rebind(to: makeInfo(id: "new"))

        #expect(model.info.id == "new")
        #expect(model.rowIdentity == "old")
        #expect(model.hashable == identifierBeforeRebind)
        #expect(!handler.resetEmptyBlockForkCalled)
    }

    @Test func identityUndoRebindRestoresInfoAndResetsHandlerFork() {
        let handler = TextBlockActionHandlerStub()
        let model = makeModel(blockId: "old", handler: handler)
        let identifierBeforeRebind = model.hashable
        model.rebind(to: makeInfo(id: "new"))

        model.rebindAfterIdentityUndo(to: makeInfo(id: "old"))

        #expect(model.info.id == "old")
        #expect(model.hashable == identifierBeforeRebind)
        #expect(handler.resetEmptyBlockForkCalled)
    }

    private func makeModel(blockId: String, handler: TextBlockActionHandlerStub) -> TextBlockViewModel {
        let document = MockBaseDocument()
        return TextBlockViewModel(
            document: document,
            blockInformationProvider: BlockModelInfomationProvider(document: document, info: makeInfo(id: blockId)),
            actionHandler: handler,
            cursorManager: EditorCursorManager(focusSubjectHolder: FocusSubjectsHolder()),
            rowIdentity: blockId
        )
    }

    private func makeInfo(id: String) -> BlockInformation {
        .empty(id: id, content: .text(.empty(contentType: .text)))
    }
}

@MainActor
private final class TextBlockActionHandlerStub: TextBlockActionHandlerProtocol {
    var info: BlockInformation = .empty(id: "stub", content: .text(.empty(contentType: .text)))
    let resetSubject = PassthroughSubject<NSAttributedString?, Never>()
    let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
    private(set) var resetEmptyBlockForkCalled = false

    func textBlockActions() -> TextBlockContentConfiguration.Actions {
        TextBlockContentConfiguration.Actions(
            shouldPaste: { _, _ in false },
            copy: { _ in },
            cut: { _ in },
            createEmptyBlock: { },
            showObject: { _ in },
            openURL: { _ in },
            handleKeyboardAction: { _, _ in },
            becomeFirstResponder: { },
            resignFirstResponder: { },
            textBlockSetNeedsLayout: { _ in },
            textViewDidChangeText: { _ in },
            textViewWillBeginEditing: { _ in },
            textViewDidBeginEditing: { _ in },
            textViewDidEndEditing: { _ in },
            textViewDidChangeCaretPosition: { _, _ in },
            textViewShouldReplaceText: { _, _, _ in false },
            toggleCheckBox: { },
            toggleDropDown: { },
            tapOnCalloutIcon: { },
            escalateToBlockSelection: { }
        )
    }

    func resetEmptyBlockFork() {
        resetEmptyBlockForkCalled = true
    }
}
