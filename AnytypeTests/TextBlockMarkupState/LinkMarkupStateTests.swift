import XCTest
@testable import Anytype

final class LinkMarkupStateTests: XCTestCase {
    
    private var exampleString: NSAttributedString!
    private var wholeStringWithMarkup: NSAttributedString!
    
    // This is for convenience, you can see which value has each part of attributed string
    private let attributedStringBlueprint: [(NSRange, Any?)] = [
        (NSRange(location: 0, length: 3), nil),
        (NSRange(location: 3, length: 4), nil),
        (NSRange(location: 7, length: 4), URL(string: "https://yandex.ru")),
        (NSRange(location: 11, length: 2), nil),
        (NSRange(location: 13, length: 6), URL(string: "https://google.com")),
        (NSRange(location: 19, length: 3), URL(string: "https://google.com")),
        (NSRange(location: 22, length: 6), "Simple string"),
        (NSRange(location: 28, length: 5), 42),
        (NSRange(location: 33, length: 7), URL(string: "https://yandex.ru")),
        (NSRange(location: 40, length: 10), nil),
        (NSRange(location: 50, length: 8), "https://yandex.ru")
    ]
    
    override func setUp() {
        let result = NSMutableAttributedString()
        
        attributedStringBlueprint.forEach { range, value in
            let string = Array(repeating: "a", count: range.length).joined()
            result.append(NSAttributedString(string: string))
            if let value = value {
                result.addAttribute(.link, value: value, range: range)
            }
        }
        exampleString = NSAttributedString(attributedString: result)
        
        wholeStringWithMarkup = NSAttributedString(
            string: "aaaaaaaaaaaaaaaa",
            attributes: [.link: URL(string: "https://yandex.ru") as Any]
        )
    }
    
    func testIncorrectRangeLocation() {
        // Given
        let rangeWithIncorrectLocation = NSRange(location: -20, length: 42)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: rangeWithIncorrectLocation)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertFalse(hasMarkup)
    }

    func testIncorrectRangeLength() {
        // Given
        let rangeWithIncorrentLength = NSRange(location: 12, length: 44444)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: rangeWithIncorrentLength)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertFalse(hasMarkup)
    }

    func testWholeStringRange() {
        // Given
        let range = NSRange(location: 0, length: exampleString.length)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertFalse(hasMarkup)
    }

    func testCompletelyWithoutMatchingRange() {
        // Given
        let range = NSRange(location: 22, length: 6)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertFalse(hasMarkup)
    }

    func testWithOnlyFirstHalfRangeMatching() {
        // Given
        let range = NSRange(location: 33, length: 17)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertFalse(hasMarkup)
    }

    func testMatchingRangeWithAttachment() {
        // Given
        let initialRange = NSRange(location: 7, length: 4)
        let url: URL? = exampleString.value(for: .link, range: initialRange)
        let hasMarkup = url.isNotNil

        let stringWithAttachment = NSMutableAttributedString(attributedString: exampleString)
        let attachmentString = NSAttributedString(attachment: NSTextAttachment())
        stringWithAttachment.insert(attachmentString, at: 7)

        let range = NSRange(location: initialRange.location, length: initialRange.length + 1)
        let resultURL: URL? = stringWithAttachment.value(for: .link, range: range)
        let hasURLInRangeWithAttachment = resultURL.isNotNil

        XCTAssertTrue(hasMarkup)
        XCTAssertFalse(hasURLInRangeWithAttachment)
    }

    func testWithOnlySecondHalfRangeMatching() {
        // Given
        let range = NSRange(location: 11, length: 8)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertFalse(hasMarkup)
    }
    
    func testWitoutLinkRange() {
        // Given
        let range = NSRange(location: 7, length: 6)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertFalse(hasMarkup)
    }

    func testWholeStringWithLink() {
        // Given
        let range = NSRange(location: 0, length: wholeStringWithMarkup.length)
        
        // When
        let url: URL? = wholeStringWithMarkup.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertTrue(hasMarkup)
    }

    func testMatchingRangeInOneLink() {
        // Given
        let range = NSRange(location: 13, length: 6)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertTrue(hasMarkup)
    }

    func testMatchingRangeInTwoLinks() {
        // Given
        let range = NSRange(location: 13, length: 9)
        
        // When
        let url: URL? = exampleString.value(for: .link, range: range)
        
        // Then
        let hasMarkup = url.isNotNil
        XCTAssertTrue(hasMarkup)
    }
}
