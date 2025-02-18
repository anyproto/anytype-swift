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
                link: URL(string: "h://a.b")!,
                text: NSAttributedString(string: "A h://a.b ")
            )
        ),
        // New Line. Input
        (
            NSAttributedString(string: "A h://a.b"),
            NSRange(location: 9, length: 0),
            "\n",
            ChatInputLinkParserChange.addLinkStyle(
                range: NSRange(location: 2, length: 7),
                link: URL(string: "h://a.b")!,
                text: NSAttributedString(string: "A h://a.b\n")
            )
        )
    ])
    func testSpace(
        _ source: NSAttributedString,
        _ range: NSRange,
        _ replacementText: String,
        _ expectedResult: ChatInputLinkParserChange?
    ) async throws {
        let result = parser.handleInput(sourceText: source, range: range, replacementText: replacementText)
        #expect(result == expectedResult)
    }
}
