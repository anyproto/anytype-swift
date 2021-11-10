import XCTest
@testable import Anytype
@testable import BlocksModels

class MarkdownTests: XCTestCase {

    var listener: MarkdownListenerImpl!
    var handler: BlockActionHandlerMock!
    var changer: BlockMarkupChangerMock!
    
    override func setUpWithError() throws {
        handler = BlockActionHandlerMock()
        changer = BlockMarkupChangerMock()
        listener = MarkdownListenerImpl(handler: handler, markupChanger: changer)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMarkdownTitle() throws {
        let data = buildData(text: "# ", carretPosition: 2)
        handler.turnIntoStub = true
        handler.changeTextStub = true
        
        listener.textDidChange(changeType: .typingSymbols, data: data)
        
        XCTAssertEqual(handler.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(handler.turnIntoStyleFromLastCall!, .header)
        XCTAssertEqual(handler.changeTextNumberOfCalls, 1)
        XCTAssertEqual(handler.changeTextTextFromLastCall!.string, "")
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

extension UITextView {
    open override var isFirstResponder: Bool { true }
}
