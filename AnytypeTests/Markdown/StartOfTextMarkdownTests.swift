import XCTest
@testable import Anytype
@testable import BlocksModels

class StartOfTextMarkdownTests: XCTestCase {

    var listener: MarkdownListenerImpl!
    var handler: BlockActionHandlerMock!
    var changer: BlockMarkupChangerMock!
    
    override func setUpWithError() throws {
        handler = BlockActionHandlerMock()
        changer = BlockMarkupChangerMock()
        listener = MarkdownListenerImpl(markupChanger: changer)
    }
    
    func testStartOfTextMarkdowns_triggered_on_every_carret_position_inside_shortcut() throws {
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                (0...text.count).forEach { index in
                    testStartOfTextMarkdown(shortcut: text, style: shortcut.style, carretPosition: index, success: true)
                }
                testStartOfTextMarkdown(shortcut: text, style: shortcut.style, carretPosition: text.count + 1, success: false)
            }
        }
    }

    func testStartOfTextMarkdowns() throws {
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                testStartOfTextMarkdown(shortcut: text, style: shortcut.style)
            }
        }
    }
    
    func testStartOfTextMarkdowns_did_not_trigger_on_delete() throws {
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                testStartOfTextMarkdown(shortcut: text, style: shortcut.style, changeType: .deletingSymbols, success: false)
            }
        }
    }
    
    private func testStartOfTextMarkdown(
        shortcut: String,
        style: BlockText.Style,
        changeType: TextChangeType = .typingSymbols,
        carretPosition: Int? = nil,
        success: Bool = true
    ) {
        let data = buildData(text: shortcut + "Equilibrium", carretPosition: carretPosition ?? shortcut.count)
        handler.turnIntoStub = true
        handler.changeTextStub = true

        listener.textDidChange(changeType: changeType, data: data)
        
        if success {
            XCTAssertEqual(handler.turnIntoNumberOfCalls, 1)
            XCTAssertEqual(handler.turnIntoStyleFromLastCall!, style)
            XCTAssertEqual(handler.changeTextNumberOfCalls, 1)
            XCTAssertEqual(handler.changeTextTextFromLastCall!.string, "Equilibrium")
        } else {
            XCTAssertEqual(handler.turnIntoNumberOfCalls, 0)
            XCTAssertEqual(handler.changeTextNumberOfCalls, 0)
        }
        
        handler.turnIntoNumberOfCalls = 0
        handler.changeTextNumberOfCalls = 0
    }

    private func buildData(text: String, carretPosition: Int) -> TextBlockDelegateData {
        let textView = UITextView()
        textView.text = text
        textView.selectedRange = NSRange(location: carretPosition, length: 0)
        
        let block = BlockModelMock(information: .emptyText)
        let text = UIKitAnytypeText(text: text, style: .body)
        
        return TextBlockDelegateData(textView: textView, block: block, text: text)
    }
}
