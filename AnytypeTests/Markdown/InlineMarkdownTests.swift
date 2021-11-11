import XCTest
@testable import Anytype
@testable import BlocksModels

class InlineMarkdownTests: XCTestCase {

    var listener: MarkdownListenerImpl!
    var handler: BlockActionHandlerMock!
    var changer: BlockMarkupChangerMock!
    
    override func setUpWithError() throws {
        handler = BlockActionHandlerMock()
        changer = BlockMarkupChangerMock()
        listener = MarkdownListenerImpl(handler: handler, markupChanger: changer)
    }
    
    func testInlineMarkups() {
        testInlineMarkdown(shortcut: "`", markup: .keyboard)
        testInlineMarkdown(shortcut: "_", markup: .italic)
        testInlineMarkdown(shortcut: "*", markup: .italic)
        testInlineMarkdown(shortcut: "__", markup: .bold)
        testInlineMarkdown(shortcut: "**", markup: .bold)
        testInlineMarkdown(shortcut: "~~", markup: .strikethrough)
    }
    
    func testInlineMarkups_not_trigger_on_empty_text() {
        testInlineMarkdown(shortcut: "`", markup: .keyboard, initialText: "", success: false)
        testInlineMarkdown(shortcut: "_", markup: .italic, initialText: "", success: false)
        testInlineMarkdown(shortcut: "*", markup: .italic, initialText: "", success: false)
        testInlineMarkdown(shortcut: "__", markup: .bold, initialText: "", success: false)
        testInlineMarkdown(shortcut: "**", markup: .bold, initialText: "", success: false)
        testInlineMarkdown(shortcut: "~~", markup: .strikethrough, initialText: "", success: false)
    }
    
    private func testInlineMarkdown(
        shortcut: String,
        markup: MarkupType,
        initialText: String = "Equilibrium",
        success: Bool = true
    ) {
        let text = shortcut + initialText + shortcut
        let data = buildData(text: text, carretPosition: text.count)
        changer.toggleMarkupInRangeStubReturnString = NSAttributedString(string: text)
        handler.changeTextStub = true
        handler.changeCaretPositionStub = true
        
        listener.textDidChange(changeType: .typingSymbols, data: data)
        
        if success {
            XCTAssertEqual(changer.toggleMarkupInRangeNumberOfCalls, 1)
            XCTAssertEqual(changer.toggleMarkupInRangeLastMarkupType, markup)
            XCTAssertEqual(changer.toggleMarkupInRangeLastRange, NSRange(location: shortcut.count, length: initialText.count))
            XCTAssertEqual(handler.changeTextNumberOfCalls, 1)
            XCTAssertEqual(handler.changeTextTextFromLastCall?.string, initialText)
            XCTAssertEqual(handler.changeCaretPositionNumberOfCalls, 1)
            XCTAssertEqual(handler.changeCaretPositionLastRange, NSRange(location: initialText.count, length: 0))
        } else {
            XCTAssertEqual(changer.toggleMarkupInRangeNumberOfCalls, 0)
            XCTAssertEqual(handler.changeTextNumberOfCalls, 0)
            XCTAssertEqual(handler.changeCaretPositionNumberOfCalls, 0)
        }
        
        changer.toggleMarkupInRangeNumberOfCalls = 0
        handler.changeTextNumberOfCalls = 0
        handler.changeCaretPositionNumberOfCalls = 0
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
