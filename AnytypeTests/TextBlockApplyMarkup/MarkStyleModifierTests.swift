import XCTest
@testable import Anytype

final class MarkStyleModifierTests: XCTestCase {
    
    private var sut = MarkStyleModifier(defaultNonCodeFont: .body)
    private let defaultFont = UIFont.body
    
    private var wholeStringRange: NSRange {
        NSRange(location: 0, length: sut.attributedString.length)
    }
    private var isWholeItalic: Bool {
        sut.attributedString.isFontInWhole(range: wholeStringRange, has: .traitItalic)
    }
    private var isWholeBold: Bool {
        sut.attributedString.isFontInWhole(range: wholeStringRange, has: .traitBold)
    }
    private var isWholeCode: Bool {
        sut.attributedString.isCodeFontInWhole(range: wholeStringRange)
    }
    private var isWholeStrikethrough: Bool {
        sut.attributedString.isEverySymbol(in: wholeStringRange, has: .strikethroughStyle)
    }
    
    override func setUp() {
        let string = NSMutableAttributedString(
            string: "Some string to test MarkStyleModifier entity!",
            attributes: [.font: defaultFont])
        sut = MarkStyleModifier(attributedText: string, defaultNonCodeFont: defaultFont)
    }
    
    // MARK: Whole string markup
    
    func testOnlyCodeMarkupApply() {
        applyToWholeString(.keyboard(true))
        
        XCTAssertTrue(isWholeCode)
    }
    
    func testOnlyBoldMarkupApply() {
        applyToWholeString(.bold(true))
        
        XCTAssertTrue(isWholeBold)
    }
    
    func testOnlyItalicMarkupApply() {
        applyToWholeString(.italic(true))
        
        XCTAssertTrue(isWholeItalic)
    }
    
    func testOnlyStrikethroughMarkupApply() {
        applyToWholeString(.strikethrough(true))
        
        XCTAssertTrue(isWholeStrikethrough)
    }
    
    func testBoldAndItalicWholeString() {
        applyToWholeString(.bold(true))
        applyToWholeString(.italic(true))
        
        XCTAssertTrue(isWholeBold)
        XCTAssertTrue(isWholeItalic)
    }
    
    func testBoldAndCodeWholeString() {
        applyToWholeString(.bold(true))
        applyToWholeString(.keyboard(true))
        
        XCTAssertTrue(isWholeCode)
        XCTAssertTrue(isWholeBold)
    }
    
    func testBoldAndStrikethroughWholeString() {
        applyToWholeString(.bold(true))
        applyToWholeString(.strikethrough(true))
        
        XCTAssertTrue(isWholeStrikethrough)
        XCTAssertTrue(isWholeBold)
    }
    
    func testItalicAndCodeWholeString() {
        applyToWholeString(.keyboard(true))
        applyToWholeString(.italic(true))
        
        XCTAssertTrue(isWholeItalic)
        XCTAssertTrue(isWholeCode)
    }
    
    func testItalicAndStrikethroughWholeString() {
        applyToWholeString(.strikethrough(true))
        applyToWholeString(.italic(true))
        
        XCTAssertTrue(isWholeItalic)
        XCTAssertTrue(isWholeStrikethrough)
    }
    
    func tesCodeAndStrikethroughWholeString() {
        applyToWholeString(.keyboard(true))
        applyToWholeString(.strikethrough(true))
        
        XCTAssertTrue(isWholeCode)
        XCTAssertTrue(isWholeStrikethrough)
    }
    
    func testBoldItalicCodeStrikethroughMarkupsToWholeString() {
        applyToWholeString(.keyboard(true))
        applyToWholeString(.bold(true))
        applyToWholeString(.italic(true))
        applyToWholeString(.strikethrough(true))
        
        XCTAssertTrue(isWholeCode)
        XCTAssertTrue(isWholeStrikethrough)
        XCTAssertTrue(isWholeItalic)
        XCTAssertTrue(isWholeBold)
    }
    
    // MARK: Overlapping
    
    func testBoldAndItalicOverlapping() {
        let (hasBold, hasItalic) = applyOverlappingMarkups(
            first: .bold(true),
            second: .italic(true),
            firstRange: NSRange(location: 2, length: 5),
            secondRange: NSRange(location: 3, length: 7)
        )
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasItalic)
    }
    
    func testBoldAndCodeOverlapping() {
        let (hasBold, hasCode) = applyOverlappingMarkups(
            first: .bold(true),
            second: .keyboard(true),
            firstRange: NSRange(location: 2, length: 5),
            secondRange: NSRange(location: 3, length: 7)
        )
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasCode)
    }
    
    func testBoldAndStrikethroughOverlapping() {
        let (hasBold, hasStrikethrough) = applyOverlappingMarkups(
            first: .bold(true),
            second: .strikethrough(true),
            firstRange: NSRange(location: 2, length: 5),
            secondRange: NSRange(location: 3, length: 7)
        )
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasStrikethrough)
    }
    
    func testItalicAndCodeOverlapping() {
        let (hasCode, hasItalic) = applyOverlappingMarkups(
            first: .keyboard(true),
            second: .italic(true),
            firstRange: NSRange(location: 2, length: 5),
            secondRange: NSRange(location: 3, length: 7)
        )
        XCTAssertTrue(hasCode)
        XCTAssertTrue(hasItalic)
    }
    
    func testItalicAndStrikethroughOverlapping() {
        let (hasStrikethrough, hasItalic) = applyOverlappingMarkups(
            first: .strikethrough(true),
            second: .italic(true),
            firstRange: NSRange(location: 2, length: 5),
            secondRange: NSRange(location: 3, length: 7)
        )
        XCTAssertTrue(hasStrikethrough)
        XCTAssertTrue(hasItalic)
    }
    
    func testStrikethroughAndCodeOverlapping() {
        let (hasStrikethrough, hasCode) = applyOverlappingMarkups(
            first: .strikethrough(true),
            second: .keyboard(true),
            firstRange: NSRange(location: 2, length: 5),
            secondRange: NSRange(location: 3, length: 7)
        )
        XCTAssertTrue(hasStrikethrough)
        XCTAssertTrue(hasCode)
    }
    
    // MARK: Markup then Mention
    
    func testBoldMarkupAndThenMention() {
        let hasMarkup = applyMarkupAndInsertMention(
            .bold(true),
            markRange: NSRange(location: 3, length: 10),
            mentionRange: NSRange(location: 4, length: 4)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testItalicMarkupAndThenMention() {
        let hasMarkup = applyMarkupAndInsertMention(
            .italic(true),
            markRange: NSRange(location: 3, length: 10),
            mentionRange: NSRange(location: 4, length: 4)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testCodeMarkupAndThenMention() {
        let hasMarkup = applyMarkupAndInsertMention(
            .keyboard(true),
            markRange: NSRange(location: 3, length: 10),
            mentionRange: NSRange(location: 4, length: 4)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testStrikethroughMarkupAndThenMention() {
        let hasMarkup = applyMarkupAndInsertMention(
            .strikethrough(true),
            markRange: NSRange(location: 3, length: 10),
            mentionRange: NSRange(location: 4, length: 4)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    // MARK: Mention then Markup
    
    func testInsertMentionAndThenApplyBold() {
        let hasMarkup = applyMentionAndThenMarkup(
            .bold(true),
            mentionRange: NSRange(location: 5, length: 5),
            markRange: NSRange(location: 4, length: 8)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testInsertMentionAndThenApplyItalic() {
        let hasMarkup = applyMentionAndThenMarkup(
            .italic(true),
            mentionRange: NSRange(location: 5, length: 5),
            markRange: NSRange(location: 4, length: 8)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testInsertMentionAndThenApplyCode() {
        let hasMarkup = applyMentionAndThenMarkup(
            .keyboard(true),
            mentionRange: NSRange(location: 5, length: 5),
            markRange: NSRange(location: 4, length: 8)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testInsertMentionAndThenApplyStrikethrough() {
        let hasMarkup = applyMentionAndThenMarkup(
            .strikethrough(true),
            mentionRange: NSRange(location: 5, length: 5),
            markRange: NSRange(location: 4, length: 8)
        )
        XCTAssertTrue(hasMarkup)
    }
    
    private func applyMentionAndThenMarkup(
        _ mark: MarkStyle,
        mentionRange: NSRange,
        markRange: NSRange
    ) -> Bool {
        if !isRangeValid(mentionRange) || !isRangeValid(markRange) {
            XCTFail("Ranges out of bounds")
        }
        sut.applyStyle(style: .mention("randomPage"), range: mentionRange)
        sut.applyStyle(style: mark, range: markRange)
        return isThereMarkup(mark: mark, at: markRange)
    }
    
    private func applyMarkupAndInsertMention(
        _ mark: MarkStyle,
        markRange: NSRange,
        mentionRange: NSRange
    ) -> Bool {
        if !isRangeValid(mentionRange) || !isRangeValid(markRange) {
            XCTFail("Ranges out of bounds")
        }
        sut.applyStyle(style: mark, range: markRange)
        sut.applyStyle(style: .mention("randomPage"), range: mentionRange)
        return isThereMarkup(mark: mark, at: markRange)
    }
    
    private func applyOverlappingMarkups(
        first: MarkStyle,
        second: MarkStyle,
        firstRange: NSRange,
        secondRange: NSRange
    ) -> (Bool, Bool) {
        if !isRangeValid(firstRange) || !isRangeValid(secondRange) {
            XCTFail("Ranges out of bounds")
        }
        sut.applyStyle(style: first, range: firstRange)
        sut.applyStyle(style: second, range: secondRange)
        
        return (isThereMarkup(mark: first, at: firstRange), isThereMarkup(mark: second, at: secondRange))
    }
    
    private func isRangeValid(_ range: NSRange) -> Bool {
        sut.attributedString.isRangeValid(range)
    }
    
    private func isThereMarkup(mark: MarkStyle, at range: NSRange) -> Bool {
        switch mark {
        case let .bold(hasBold):
            return sut.attributedString.isFontInWhole(range: range, has: .traitBold) == hasBold
        case let .italic(hasItalic):
            return sut.attributedString.isFontInWhole(range: range, has: .traitItalic) == hasItalic
        case let .keyboard(hasCode):
            return sut.attributedString.isCodeFontInWhole(range: range) == hasCode
        case let .strikethrough(hasValue):
            return sut.attributedString.isEverySymbol(in: range, has: .strikethroughStyle) == hasValue
        case let .backgroundColor(color):
            let value = sut.attributedString.attribute(
                .backgroundColor,
                at: range.location,
                longestEffectiveRange: nil,
                in: range
            ) as? UIColor
            return value == color
        case let .textColor(color):
            let value = sut.attributedString.attribute(
                .foregroundColor,
                at: range.location,
                longestEffectiveRange: nil,
                in: range
            ) as? UIColor
            return value == color
        case let .mention(pageId):
            let value = sut.attributedString.attribute(
                .mention,
                at: range.location,
                longestEffectiveRange: nil,
                in: range
            ) as? String
            return value == pageId
        case .link, .underscored:
            assertionFailure("Unimplemented \(mark)")
            return false
        }
    }
    
    private func applyToWholeString(_ mark: MarkStyle) {
        sut.applyStyle(style: mark, range: wholeStringRange)
    }
}
