import Foundation
import XCTest
@testable import Anytype

class InlineMarkdownListenerTests: XCTestCase {
    
    struct Case {
        let text: String
        let inputText: String
        
        var range: NSRange {
            return NSRange(location: text.count, length: 0)
        }
    }
    
    var listener: MarkdownListener!
    
    override func setUpWithError() throws {
        listener = InlineMarkdownListener()
    }
 
    func test_AllCases() {
        
        let cases = [
            Case(text:"AAA`bbb", inputText: "`"),
            Case(text:"AAA‘bbb", inputText: "‘"),
            Case(text:"AAA'bbb", inputText: "'"),
            Case(text:"AAA‘bbb", inputText: "'"),
            Case(text:"AAA’bbb", inputText: "'"),
            Case(text:"AAA’bb", inputText: "b"),
            Case(text:"AAA’’bb", inputText: "b"),
            Case(text:"AAA_bbb", inputText: "_"),
            Case(text:"AAA*bbb", inputText: "*"),
            Case(text:"AAA__bbb_", inputText: "_"),
            Case(text:"AAA__bbb", inputText: "_"),
            Case(text:"AAA**bbb*", inputText: "*"),
            Case(text:"AAA**bbb", inputText: "*"),
            Case(text:"AAA~~bbb~", inputText: "~"),
            Case(text:"AAA~~bbb", inputText: "~")
        ]
        
        let text = NSAttributedString(string: "AAAbbb")
        let range = NSRange(location: 3, length: 3)
        
        let expectedResults: [MarkdownChange?] = [
            .addStyle(.keyboard, text: text, range: range),
            .addStyle(.keyboard, text: text, range: range),
            .addStyle(.keyboard, text: text, range: range),
            .addStyle(.keyboard, text: text, range: range),
            .addStyle(.keyboard, text: text, range: range),
            nil,
            nil,
            .addStyle(.italic, text: text, range: range),
            .addStyle(.italic, text: text, range: range),
            .addStyle(.bold, text: text, range: range),
            nil,
            .addStyle(.bold, text: text, range: range),
            nil,
            .addStyle(.strikethrough, text: text, range: range),
            nil
        ]
        
        let textView = UITextView()
        
        let results = cases.map {
            textView.text = $0.text
            return listener.markdownChange(textView: textView, replacementText: $0.inputText, range: $0.range)
        }
    
        XCTAssertEqual(expectedResults.count, results.count)
        
        for i in 0..<expectedResults.count {
            switch (expectedResults[i], results[i]) {
            case let (.addStyle(expectedStyle, expectedText, expectedRange), .addStyle(style, text, range)):
                XCTAssertEqual(expectedStyle, style)
                XCTAssertEqual(expectedText.string, text.string)
                XCTAssertEqual(expectedRange, range)
            case (nil, nil):
                break
            default:
                XCTFail("Wrong case")
            }
        }
    }
}
