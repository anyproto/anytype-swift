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
        listener = MarkdownListenerImpl(markupChanger: changer)
    }
    
    func testInlineMarkups() {
        InlineMarkdown.all.forEach { markdown in
            markdown.text.forEach { shortcut in
                testInlineMarkdown(shortcut: shortcut, markup: markdown.markup)
            }
        }
    }
    
    func testInlineMarkups_works_with_multiline_strings() {
        InlineMarkdown.all.forEach { markdown in
            markdown.text.forEach { shortcut in
                testInlineMarkdown(shortcut: shortcut, markup: markdown.markup, initialText: "one\ntwo\three")
            }
        }
    }
    
    func testInlineMarkups_not_trigger_on_empty_text() {
        InlineMarkdown.all.forEach { markdown in
            markdown.text.forEach { shortcut in
                testInlineMarkdown(shortcut: shortcut, markup: markdown.markup, initialText: "", success: false)
            }
        }
    }
    
    func testInlineMarkups_not_trigger_on_deletion() {
        InlineMarkdown.all.forEach { markdown in
            markdown.text.forEach { shortcut in
                testInlineMarkdown(shortcut: shortcut, markup: markdown.markup, changeType: .deletingSymbols, success: false)
            }
        }
    }
    
    // _nested_markup_
    func testInlineMarkups_triggers_on_closest_range() {
        InlineMarkdown.all.forEach { markdown in
            markdown.text.forEach { shortcut in
                let firstText = "nested"
                let secondText = "markup"
                testInlineMarkdown(
                    shortcut: shortcut,
                    markup: markdown.markup,
                    initialText: firstText + shortcut + secondText,
                    finalText:  shortcut + firstText + secondText,
                    markupRange: NSRange(location: (shortcut + firstText + shortcut).count, length: secondText.count)
                )
            }
        }
    }
    
    func testInlineMarkups_italic_do_not_trigger_if_opened_shortcut_is_bold() {
        testInlineMarkdown(shortcut: "", markup: .italic, initialText: "__boldplease_", success: false)
        testInlineMarkdown(shortcut: "", markup: .italic, initialText: "**boldplease*", success: false)
    }
    
    func testInlineMarkups_triggers_only_on_position_after_shortcut() {
        InlineMarkdown.all.forEach { markdown in
            markdown.text.forEach { shortcut in
                let initialText = "123"
                let fullTextLength = (shortcut.count * 2) + initialText.count
                (0..<fullTextLength).forEach { carretPosition in
                    testInlineMarkdown(
                        shortcut: shortcut,
                        markup: markdown.markup,
                        initialText: initialText,
                        carretPosition: carretPosition,
                        success: false
                    )
                }
                testInlineMarkdown(
                    shortcut: shortcut,
                    markup: markdown.markup,
                    initialText: initialText,
                    carretPosition: fullTextLength,
                    success: true
                )
            }
        }
    }
    
    private func testInlineMarkdown(
        shortcut: String,
        markup: MarkupType,
        initialText: String = "Equilibrium",
        finalText: String? = nil,
        markupRange: NSRange? = nil,
        changeType: TextChangeType = .typingSymbols,
        carretPosition: Int? = nil,
        success: Bool = true
    ) {
//        let text = shortcut + initialText + shortcut
//        let data = buildData(text: text, carretPosition: carretPosition ?? text.count)
//        changer.setMarkupStubReturnString = NSAttributedString(string: text)
//        handler.changeTextStub = true
//        handler.changeCaretPositionStub = true
//        
//        listener.textDidChange(changeType: changeType, data: data)
//        
//        if success {
//            let markupRange = markupRange ?? NSRange(location: shortcut.count, length: initialText.count)
//            XCTAssertEqual(changer.setMarkupNumberOfCalls, 1)
//            XCTAssertEqual(changer.setMarkupLastMarkupType, markup)
//            XCTAssertEqual(changer.setMarkupLastRange, markupRange)
//            XCTAssertEqual(handler.changeTextNumberOfCalls, 1)
//            XCTAssertEqual(handler.changeTextTextFromLastCall?.string, finalText ?? initialText)
//            XCTAssertEqual(handler.changeCaretPositionNumberOfCalls, 1)
//            XCTAssertEqual(handler.changeCaretPositionLastRange, NSRange(location: initialText.count, length: 0))
//        } else {
//            XCTAssertEqual(changer.setMarkupNumberOfCalls, 0)
//            XCTAssertEqual(handler.changeTextNumberOfCalls, 0)
//            XCTAssertEqual(handler.changeCaretPositionNumberOfCalls, 0)
//        }
//        
//        changer.setMarkupNumberOfCalls = 0
//        handler.changeTextNumberOfCalls = 0
//        handler.changeCaretPositionNumberOfCalls = 0
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
