import Foundation
import XCTest
@testable import Anytype


@MainActor
class InlineMarkdownListenerTests: XCTestCase {
    
    struct Case {
        let text: String
        let inputText: String
        let range: NSRange
        
        init(text: String, inputText: String, range: NSRange? = nil) {
            self.text = text
            self.inputText = inputText
            self.range = range ?? NSRange(location: text.count, length: 0)
        }
    }
    
    var listener: MarkdownListener!
    
    override func setUpWithError() throws {
        listener = InlineMarkdownListener()
    }
 
    func test_AllCases() {
        
        let cases = [
            Case(text:"AAA`bbb", inputText: "`"),
            Case(text:"AAA’bb", inputText: "b"),
            Case(text:"AAA’’bb", inputText: "b"),
            Case(text:"AAA_bbb", inputText: "_"),
            Case(text:"AAA*bbb", inputText: "*"),
            Case(text:"AAA__bbb_", inputText: "_"),
            Case(text:"AAA__bbb", inputText: "_"),
            Case(text:"AAA**bbb*", inputText: "*"),
            Case(text:"AAA**bbb", inputText: "*"),
            Case(text:"AAA~~bbb~", inputText: "~"),
            Case(text:"AAA~~bbb", inputText: "~"),
            // Middle cursor position
            Case(text:"AAA~~bbb~ccc", inputText: "~", range: NSRange(location: 9, length: 0)),
        ]
        
        let text = NSAttributedString(string: "AAAbbb ")
        let range = NSRange(location: 3, length: 3)
        let focusRange = NSRange(location: 7, length: 0)
        
        let expectedResults: [MarkdownChange?] = [
            .addStyle(.keyboard, text: text, range: range, focusRange: focusRange),
            nil,
            nil,
            .addStyle(.italic, text: text, range: range, focusRange: focusRange),
            .addStyle(.italic, text: text, range: range, focusRange: focusRange),
            .addStyle(.bold, text: text, range: range, focusRange: focusRange),
            nil,
            .addStyle(.bold, text: text, range: range, focusRange: focusRange),
            nil,
            .addStyle(.strikethrough, text: text, range: range, focusRange: focusRange),
            nil,
            .addStyle(.strikethrough, text: NSAttributedString(string: "AAAbbb ccc"), range: range, focusRange: focusRange)
        ]
        
        let textView = UITextView()
        
        let results = cases.map {
            textView.text = $0.text
            return listener.markdownChange(textView: textView, replacementText: $0.inputText, range: $0.range)
        }
    
        XCTAssertEqual(expectedResults.count, results.count)
        
        for i in 0..<expectedResults.count {
            switch (expectedResults[i], results[i]) {
            case let (
                .addStyle(expectedStyle, expectedText, expectedRange, expectedFocusRange),
                .addStyle(style, text, range, focusRange)):
                XCTAssertEqual(expectedStyle, style)
                XCTAssertEqual(expectedText.string, text.string)
                XCTAssertEqual(expectedRange, range)
                XCTAssertEqual(expectedFocusRange, focusRange)
            case (nil, nil):
                break
            default:
                XCTFail("Wrong case")
            }
        }
    }
}
