import Testing
import Foundation
@testable import Anytype

struct ChatInputLinkParserTests {

    let parser = ChatInputLinkParser()
    
    @Test(arguments: [
        // Spaces. Input
        (
            NSAttributedString(string: "A h://a.b"),
            NSRange(location: 9, length: 0),
            " ",
            ChatInputLinkParserChange.addLinkStyle(
                range: NSRange(location: 2, length: 7),
                link: URL(string: "h://a.b")!
            )
        ),
        // New Line. Input
        (
            NSAttributedString(string: "A h://a.b"),
            NSRange(location: 9, length: 0),
            "\n",
            ChatInputLinkParserChange.addLinkStyle(
                range: NSRange(location: 2, length: 7),
                link: URL(string: "h://a.b")!
            )
        ),
        // Text contains multiple links. Input inside
        (
            NSAttributedString(string: "A h://a.b c://d.e"),
            NSRange(location: 9, length: 0),
            " ",
            ChatInputLinkParserChange.addLinkStyle(
                range: NSRange(location: 2, length: 7),
                link: URL(string: "h://a.b")!
            )
        ),
        // Text contains multiple links. Input in end
        (
            NSAttributedString(string: "A h://a.b c://d.e"),
            NSRange(location: 17, length: 0),
            " ",
            ChatInputLinkParserChange.addLinkStyle(
                range: NSRange(location: 10, length: 7),
                link: URL(string: "c://d.e")!
            )
        )
    ])
    func testHandleInput(
        _ source: NSAttributedString,
        _ range: NSRange,
        _ replacementText: String,
        _ expectedResult: ChatInputLinkParserChange?
    ) async throws {
        let result = parser.handleInput(sourceText: source, range: range, replacementText: replacementText)
        #expect(result == expectedResult)
    }
}
