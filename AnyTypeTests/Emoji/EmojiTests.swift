import XCTest
@testable import Anytype
@testable import AnytypeCore

class EmojiTests: XCTestCase {
    func test_createFromString_to_String() {
        let emojis = EmojiProvider.shared.emojiGroups.flatMap(\.emojis)
      
        emojis.forEach {
            let emoji = Emoji($0.emoji)
            XCTAssertNotNil(emoji)
        }
    }
}
