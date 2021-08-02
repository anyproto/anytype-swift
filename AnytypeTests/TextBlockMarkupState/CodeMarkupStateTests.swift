import XCTest
@testable import Anytype

final class CodeMarkupStateTests: XCTestCase {
    
    private lazy var checker = MarkupChecker(
        markupType: .keyboard,
        attributedStringBlueprint: attributedStringBlueprint
    )
    // This is for convenience, you can see which font has each part of attributed string
    private let attributedStringBlueprint: [(NSRange, Any?)] =
        [
        (NSRange(location: 0, length: 3), nil),
        (NSRange(location: 3, length: 4), UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)),
        (NSRange(location: 7, length: 4), UIFont.code),
        (NSRange(location: 11, length: 2), nil),
            (NSRange(location: 13, length: 6), UIFont.code.adding(trait: .traitItalic) ?? UIFont.code),
        (NSRange(location: 19, length: 3), UIFont.code.adding(trait: .traitBold) ?? UIFont.code),
        (NSRange(location: 22, length: 6), UIFont.systemFont(ofSize: 22)),
        (NSRange(location: 28, length: 5), UIFont.monospacedSystemFont(ofSize: 29, weight: .regular)),
        (NSRange(location: 33, length: 7), UIFont.code),
        (NSRange(location: 40, length: 10), nil),
        (NSRange(location: 50, length: 8), UIFont.systemFont(ofSize: 18))
        ]
    
    override func setUp() {
        checker = MarkupChecker(
            markupType: .keyboard,
            attributedStringBlueprint: attributedStringBlueprint
        )
    }
    
    func testIncorrectRangeLocation() {
        let rangeWithIncorrectLocation = NSRange(location: -20, length: 42)
        let allFontsHasCode = checker.checkMarkup(in: rangeWithIncorrectLocation)
        XCTAssertFalse(allFontsHasCode)
    }

    func testIncorrectRangeLength() {
        let rangeWithIncorrentLength = NSRange(location: 12, length: 44444)
        let allFontsHasCode = checker.checkMarkup(in: rangeWithIncorrentLength)
        XCTAssertFalse(allFontsHasCode)
    }

    func testWholeStringRange() {
        let range = NSRange(location: 0, length: checker.exampleString.length)
        let allFontsHasCode = checker.checkMarkup(in: range)
        XCTAssertFalse(allFontsHasCode)
    }

    func testCompletelyWithoutMatchingRange() {
        let range = NSRange(location: 22, length: 6)
        let allFontsHasCode = checker.checkMarkup(in: range)
        XCTAssertFalse(allFontsHasCode)
    }

    func testWithOnlyFirstHalfRangeMatching() {
        let range = NSRange(location: 33, length: 17)
        let allFontsHasCode = checker.checkMarkup(in: range)
        XCTAssertFalse(allFontsHasCode)
    }

    func testMatchingRangeWithAttachment() {
        let initialRange = NSRange(location: 7, length: 4)
        let allFontsHasCode = checker.checkMarkup(in: initialRange)

        let stringWithAttachment = NSMutableAttributedString(attributedString: checker.exampleString)
        let attachmentString = NSAttributedString(attachment: NSTextAttachment())
        stringWithAttachment.insert(attachmentString, at: 7)

        let range = NSRange(location: initialRange.location, length: initialRange.length + 1)
        let resultWithAttachment = stringWithAttachment.isCodeFontInWhole(range: range)

        XCTAssertTrue(allFontsHasCode)
        XCTAssertFalse(resultWithAttachment)
    }

    func testWithOnlySecondHalfRangeMatching() {
        let range = NSRange(location: 11, length: 8)
        let hasCode = checker.checkMarkup(in: range)
        XCTAssertFalse(hasCode)
    }
    
    func testWitoutFontRange() {
        let range = NSRange(location: 7, length: 6)
        let hasCode = checker.checkMarkup(in: range)
        XCTAssertFalse(hasCode)
    }

    func testWholeStringWithCode() {
        let range = NSRange(location: 0, length: checker.wholeStringWithMarkup.length)
        let allFontsHasCode = checker.checkWholeStringWithMarkup(in: range)
        XCTAssertTrue(allFontsHasCode)
    }

    func testMatchingRangeInOneFont() {
        let range = NSRange(location: 13, length: 6)
        let allFontsHasCode = checker.checkMarkup(in: range)
        XCTAssertTrue(allFontsHasCode)
    }

    func testMatchingRangeInTwoFonts() {
        let range = NSRange(location: 13, length: 9)
        let allFontsHasCode = checker.checkMarkup(in: range)
        XCTAssertTrue(allFontsHasCode)
    }
}
