import XCTest
@testable import Anytype

final class ItalicMarkupStateTests: XCTestCase {
    
    private lazy var checker = MarkupChecker(
        markupType: .italic,
        attributedStringBlueprint: attributedStringBlueprint
    )
    private lazy var wholeStringWithMarkup = NSAttributedString(
        string: "aaaaaaaaaaaaaaaa",
        attributes: [.font: UIFont.italicSystemFont(ofSize: 33)]
    )
    // This is for convenience, you can see which font has each part of attributed string
    private lazy var attributedStringBlueprint: [(NSRange, Any?)] = [
        (NSRange(location: 0, length: 3), nil),
        (NSRange(location: 3, length: 4), UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)),
        (NSRange(location: 7, length: 4), UIFont.italicSystemFont(ofSize: 33)),
        (NSRange(location: 11, length: 2), nil),
        (NSRange(location: 13, length: 6), UIFont.italicSystemFont(ofSize: 13)),
        (NSRange(location: 19, length: 3), UIFont.italicSystemFont(ofSize: 8)),
        (NSRange(location: 22, length: 6), UIFont.systemFont(ofSize: 22)),
        (NSRange(location: 28, length: 5), UIFont.monospacedSystemFont(ofSize: 29, weight: .regular)),
        (NSRange(location: 33, length: 7), UIFont.italicSystemFont(ofSize: 11)),
        (NSRange(location: 40, length: 10), nil),
        (NSRange(location: 50, length: 8), UIFont.systemFont(ofSize: 18))
    ]
    
    func testIncorrectRangeLocation() {
        let rangeWithIncorrectLocation = NSRange(location: -20, length: 42)
        let allFontsHasTrait = checker.checkMarkup(in: rangeWithIncorrectLocation)
        XCTAssertFalse(allFontsHasTrait)
    }

    func testIncorrectRangeLength() {
        let rangeWithIncorrentLength = NSRange(location: 12, length: 44444)
        let allFontsHasTrait = checker.checkMarkup(in: rangeWithIncorrentLength)
        XCTAssertFalse(allFontsHasTrait)
    }

    func testWholeStringRange() {
        let range = NSRange(location: 0, length: checker.exampleString.length)
        let allFontsHasTrait = checker.checkMarkup(in: range)
        XCTAssertFalse(allFontsHasTrait)
    }

    func testCompletelyWithoutMatchingRange() {
        let range = NSRange(location: 22, length: 6)
        let allFontsHasTrait = checker.checkMarkup(in: range)
        XCTAssertFalse(allFontsHasTrait)
    }

    func testWithOnlyFirstHalfRangeMatching() {
        let range = NSRange(location: 33, length: 17)
        let allFontsHasTrait = checker.checkMarkup(in: range)
        XCTAssertFalse(allFontsHasTrait)
    }

    func testMatchingRangeWithAttachment() {
        let initialRange = NSRange(location: 7, length: 4)
        let allFontsHasTrait = checker.checkMarkup(in: initialRange)

        let stringWithAttachment = NSMutableAttributedString(attributedString: checker.exampleString)
        let attachmentString = NSAttributedString(attachment: NSTextAttachment())
        stringWithAttachment.insert(attachmentString, at: 7)

        let range = NSRange(location: initialRange.location, length: initialRange.length + 1)
        let resultWithAttachment = stringWithAttachment.fontInWhole(range: range, has: .traitItalic)

        XCTAssertTrue(allFontsHasTrait)
        XCTAssertFalse(resultWithAttachment)
    }

    func testWithOnlySecondHalfRangeMatching() {
        let range = NSRange(location: 11, length: 8)
        let hasTrait = checker.checkMarkup(in: range)
        XCTAssertFalse(hasTrait)
    }
    
    func testWitoutFontRange() {
        let range = NSRange(location: 7, length: 6)
        let hasTrait = checker.checkMarkup(in: range)
        XCTAssertFalse(hasTrait)
    }

    func testWholeStringWithTrait() {
        let range = NSRange(location: 0, length: wholeStringWithMarkup.length)
        let allFontsHasTrait = wholeStringWithMarkup.fontInWhole(range: range, has: .traitItalic)
        XCTAssertTrue(allFontsHasTrait)
    }

    func testMatchingRangeInOneFont() {
        let range = NSRange(location: 13, length: 6)
        let allFontsHasTrait = checker.checkMarkup(in: range)
        XCTAssertTrue(allFontsHasTrait)
    }

    func testMatchingRangeInTwoFonts() {
        let range = NSRange(location: 13, length: 9)
        let allFontsHasTrait = checker.checkMarkup(in: range)
        XCTAssertTrue(allFontsHasTrait)
    }
}
