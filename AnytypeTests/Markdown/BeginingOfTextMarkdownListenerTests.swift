import XCTest
@testable import Anytype
@testable import Services

class BeginingOfTextMarkdownListenerTests: XCTestCase {

    var listener: MarkdownListener!
    
    override func setUpWithError() throws {
        listener = BeginingOfTextMarkdownListener()
    }

    func testStartOfTextMarkdowns() throws {
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                testEnteringSpaceAfterTextMarkdown(shortcut: text, type: shortcut.type)
            }
        }
    }
    
    func testTypingALotTextOnce() {
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                testTypingALotTextOnce(insertedText: text + "testtext", expectedText: "testtext", type: shortcut.type)
            }
        }
    }
    
    private func testEnteringSpaceAfterTextMarkdown(
        shortcut: String,
        type: BlockContentType,
        success: Bool = true
    ) {
        let shortcutByDeletingSpaces = shortcut.replacingOccurrences(of: " ", with: "")
        let data = buildData(
            text: shortcutByDeletingSpaces,
            carretPosition: shortcutByDeletingSpaces.count
        )

        let markdownChange = listener.markdownChange(
            textView: data.textView,
            replacementText: " ",
            range: data.textView.selectedRange
        )

        if success {
            switch (markdownChange, type) {
            case let (.turnInto(newStyle, text: newText), .text(style)):
                XCTAssertEqual(newStyle, style)
                XCTAssertEqual(newText.string, "")
            case let (.addBlock(newType, newText), type):
                XCTAssertEqual(newType, type)
                XCTAssertEqual(newText.string, "")
            default:
                XCTFail("Wrong case")
            }
        } else {
           XCTAssertNil(markdownChange)
        }
        
    }
    
    private func testTypingALotTextOnce(
        insertedText: String,
        expectedText: String,
        type: BlockContentType
    ) {
        let data = buildData(text: "", carretPosition: 0)

        let markdownChange = listener.markdownChange(
            textView: data.textView,
            replacementText: insertedText,
            range: data.textView.selectedRange
        )

        switch (markdownChange, type) {
        case let (.turnInto(newStyle, text: newText), .text(style)):
            XCTAssertEqual(newStyle, style)
            XCTAssertEqual(newText.string, expectedText)
        case let (.addBlock(newType, newText), type):
            XCTAssertEqual(newType, type)
            XCTAssertEqual(newText.string, expectedText)
        default:
            XCTFail("Wrong case")
        }
    }

    private func buildData(text: String, carretPosition: Int) -> TextViewAccessoryConfiguration {
        let textView = UITextView()
        textView.text = text
        textView.selectedRange = NSRange(location: carretPosition, length: 0)
        
        let text = UIKitAnytypeText(text: text, style: .bodyRegular, lineBreakModel: .byWordWrapping)
        
        return TextViewAccessoryConfiguration(textView: textView, info: .emptyText, text: text, usecase: .editor)
    }
}
