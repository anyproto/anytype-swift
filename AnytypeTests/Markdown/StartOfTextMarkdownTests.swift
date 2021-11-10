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
        listener = MarkdownListenerImpl(handler: handler, markupChanger: changer)
    }

    override func tearDownWithError() throws {
    }
    
    func testChechbox_triggered_on_every_carret_position_inside_shortcut() throws {
        testStartOfTextMarkdown(shortcut: "[] ", style: .checkbox, carretPosition: 0, success: true)
        testStartOfTextMarkdown(shortcut: "[] ", style: .checkbox, carretPosition: 1, success: true)
        testStartOfTextMarkdown(shortcut: "[] ", style: .checkbox, carretPosition: 2, success: true)
        testStartOfTextMarkdown(shortcut: "[] ", style: .checkbox, carretPosition: 3, success: true)
        testStartOfTextMarkdown(shortcut: "[] ", style: .checkbox, carretPosition: 4, success: false)
    }

    func testStartOfTextMarkdowns() throws {
        testStartOfTextMarkdown(shortcut: "# ", style: .header)
        testStartOfTextMarkdown(shortcut: "## ", style: .header2)
        testStartOfTextMarkdown(shortcut: "### ", style: .header3)
        testStartOfTextMarkdown(shortcut: "\" ", style: .quote)
        testStartOfTextMarkdown(shortcut: "\' ", style: .quote)
        testStartOfTextMarkdown(shortcut: "‘ ", style: .quote)
        testStartOfTextMarkdown(shortcut: "“ ", style: .quote)
        testStartOfTextMarkdown(shortcut: "* ", style: .bulleted)
        testStartOfTextMarkdown(shortcut: "- ", style: .bulleted)
        testStartOfTextMarkdown(shortcut: "+ ", style: .bulleted)
        testStartOfTextMarkdown(shortcut: "[] ", style: .checkbox)
        testStartOfTextMarkdown(shortcut: "1. ", style: .numbered)
        testStartOfTextMarkdown(shortcut: "> ", style: .toggle)
        testStartOfTextMarkdown(shortcut: "``` ", style: .code)
    }
    
    func testStartOfTextMarkdowns_did_not_trigger_on_delete() throws {
        testStartOfTextMarkdown(shortcut: "# ", style: .header, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "## ", style: .header2, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "### ", style: .header3, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "\" ", style: .quote, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "\' ", style: .quote, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "‘ ", style: .quote, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "“ ", style: .quote, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "* ", style: .bulleted, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "- ", style: .bulleted, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "+ ", style: .bulleted, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "[] ", style: .checkbox, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "1. ", style: .numbered, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "> ", style: .toggle, changeType: .deletingSymbols, success: false)
        testStartOfTextMarkdown(shortcut: "``` ", style: .code, changeType: .deletingSymbols, success: false)
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
