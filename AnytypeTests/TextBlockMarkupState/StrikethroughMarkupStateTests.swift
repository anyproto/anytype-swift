import XCTest
@testable import Anytype

final class StrikethroughMarkupStateTests: XCTestCase {
    
    private lazy var checker = MarkupChecker(
        markupType: .strikethrough,
        attributedStringBlueprint: attributedStringBlueprint
    )
    // This is for convenience, you can see which attibute has each part of attributed string
    private let attributedStringBlueprint: [(NSRange, Any?)] = [
        (NSRange(location: 0, length: 3), nil),
        (NSRange(location: 3, length: 4), NSUnderlineStyle.single.rawValue),
        (NSRange(location: 7, length: 4), NSUnderlineStyle.double.rawValue),
        (NSRange(location: 11, length: 2), nil),
        (NSRange(location: 13, length: 6), NSUnderlineStyle.single.rawValue),
        (NSRange(location: 19, length: 3), nil),
        (NSRange(location: 22, length: 6), NSUnderlineStyle.patternDot.rawValue),
        (NSRange(location: 28, length: 5), NSUnderlineStyle.single.rawValue),
        (NSRange(location: 33, length: 7), NSUnderlineStyle.double.rawValue),
        (NSRange(location: 40, length: 10), nil),
        (NSRange(location: 50, length: 8), NSUnderlineStyle.single.rawValue)
    ]
    
    override func setUp() {
        checker = MarkupChecker(
            markupType: .strikethrough,
            attributedStringBlueprint: attributedStringBlueprint
        )
    }
    
    func testIncorrectRangeLocation() {
        let rangeWithIncorrectLocation = NSRange(location: -20, length: 42)
        let hastStrikethrough = checker.checkMarkup(in: rangeWithIncorrectLocation)
        XCTAssertFalse(hastStrikethrough)
    }

    func testIncorrectRangeLength() {
        let rangeWithIncorrentLength = NSRange(location: 12, length: 44444)
        let hastStrikethrough = checker.checkMarkup(in: rangeWithIncorrentLength)
        XCTAssertFalse(hastStrikethrough)
    }

    func testWholeStringRange() {
        let range = NSRange(location: 0, length: checker.exampleString.length)
        let hastStrikethrough = checker.checkMarkup(in: range)
        XCTAssertFalse(hastStrikethrough)
    }

    func testCompletelyWithoutMatchingRange() {
        let range = NSRange(location: 19, length: 3)
        let hastStrikethrough = checker.checkMarkup(in: range)
        XCTAssertFalse(hastStrikethrough)
    }

    func testWithOnlyFirstHalfRangeMatching() {
        let range = NSRange(location: 33, length: 17)
        let hastStrikethrough = checker.checkMarkup(in: range)
        XCTAssertFalse(hastStrikethrough)
    }

    func testMatchingRangeWithAttachment() {
        let initialRange = NSRange(location: 7, length: 4)
        let hastStrikethrough = checker.checkMarkup(in: initialRange)

        let stringWithAttachment = NSMutableAttributedString(attributedString: checker.exampleString)
        let attachmentString = NSAttributedString(attachment: NSTextAttachment())
        stringWithAttachment.insert(attachmentString, at: 7)

        let range = NSRange(location: initialRange.location, length: initialRange.length + 1)
        let resultWithAttachment = stringWithAttachment.isEverySymbol(in: range, has: .strikethroughStyle)

        XCTAssertTrue(hastStrikethrough)
        XCTAssertFalse(resultWithAttachment)
    }

    func testWithOnlySecondHalfRangeMatching() {
        let range = NSRange(location: 11, length: 8)
        let hastStrikethrough = checker.checkMarkup(in: range)
        XCTAssertFalse(hastStrikethrough)
    }
    
    func testWitoutStrikethroughRange() {
        let range = NSRange(location: 11, length: 2)
        let hastStrikethrough = checker.checkMarkup(in: range)
        XCTAssertFalse(hastStrikethrough)
    }

    func testWholeStringWithStrikethrough() {
        let range = NSRange(location: 0, length: checker.wholeStringWithMarkup.length)
        let hastStrikethrough = checker.checkWholeStringWithMarkup(in: range)
        XCTAssertTrue(hastStrikethrough)
    }

    func testMatchingRangeWithOneStyle() {
        let range = NSRange(location: 13, length: 6)
        let hastStrikethrough = checker.checkMarkup(in: range)
        XCTAssertTrue(hastStrikethrough)
    }

    func testMatchingRangeWithTwoStyles() {
        let range = NSRange(location: 22, length: 11)
        let hastStrikethrough = checker.checkMarkup(in: range)
        XCTAssertTrue(hastStrikethrough)
    }
}
