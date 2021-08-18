import XCTest
@testable import Anytype


final class MarkStyleModifierTests: XCTestCase {
    
    private var sut: MarkStyleModifier!
    
    // MARK: Overrides
    
    override func setUp() {
        let font = UIFont.body
        let string = NSMutableAttributedString(
            string: "Some string to test MarkStyleModifier entity!",
            attributes: [.font: font]
        )
        sut = MarkStyleModifier(
            attributedText: string,
            defaultNonCodeFont: font
        )
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: Whole string markup
    
    func testOnlyCodeMarkupApply() {
        // Given
        let markup = MarkStyleAction.keyboard(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            markup,
            range: range
        )
        
        // Then
        let hasMarkup = sut.attributedString.isCodeFontInWhole(range: range)
        XCTAssertTrue(hasMarkup)
    }
    
    func testOnlyBoldMarkupApply() {
        // Given
        let markup = MarkStyleAction.bold(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            markup,
            range: range
        )
        
        // Then
        let hasMarkup = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitBold
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testOnlyItalicMarkupApply() {
        // Given
        let markup = MarkStyleAction.italic(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            markup,
            range: range
        )
        
        // Then
        let hasMarkup = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitItalic
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testOnlyStrikethroughMarkupApply() {
        // Given
        let markup = MarkStyleAction.strikethrough(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            markup,
            range: range
        )
        
        // Then
        let hasMarkup = sut.attributedString.isEverySymbol(
            in: range,
            has: .strikethroughStyle
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testBoldAndItalicWholeString() {
        // Given
        let bold = MarkStyleAction.bold(true)
        let italic = MarkStyleAction.italic(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            bold,
            range: range
        )
        sut.apply(
            italic,
            range: range
        )
        
        // Then
        let hasBold = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitBold
        )
        let hasItalic = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitItalic
        )
        
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasItalic)
    }
    
    func testBoldAndCodeWholeString() {
        // Given
        let bold = MarkStyleAction.bold(true)
        let code = MarkStyleAction.keyboard(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            bold,
            range: range
        )
        sut.apply(
            code,
            range: range
        )
        
        // Then
        let hasBold = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitBold
        )
        let hasCode = sut.attributedString.isCodeFontInWhole(range: range)
        
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasCode)
    }
    
    func testBoldAndStrikethroughWholeString() {
        // Given
        let bold = MarkStyleAction.bold(true)
        let strikethrough = MarkStyleAction.strikethrough(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            bold,
            range: range
        )
        sut.apply(
            strikethrough,
            range: range
        )
        
        // Then
        let hasBold = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitBold
        )
        let hasStrikethrough = sut.attributedString.isEverySymbol(
            in: range,
            has: .strikethroughStyle
        )
        
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasStrikethrough)
    }
    
    func testItalicAndCodeWholeString() {
        // Given
        let italic = MarkStyleAction.italic(true)
        let code = MarkStyleAction.keyboard(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            italic,
            range: range
        )
        sut.apply(
            code,
            range: range
        )
        
        // Then
        let hasItalic = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitItalic
        )
        let hasCode = sut.attributedString.isCodeFontInWhole(range: range)
        
        XCTAssertTrue(hasItalic)
        XCTAssertTrue(hasCode)
    }
    
    func testItalicAndStrikethroughWholeString() {
        // Given
        let italic = MarkStyleAction.italic(true)
        let strikethrough = MarkStyleAction.strikethrough(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            italic,
            range: range
        )
        sut.apply(
            strikethrough,
            range: range
        )
        
        // Then
        let hasItalic = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitItalic
        )
        let hasStrikethrough = sut.attributedString.isEverySymbol(
            in: range,
            has: .strikethroughStyle
        )
        
        XCTAssertTrue(hasItalic)
        XCTAssertTrue(hasStrikethrough)
    }
    
    func tesCodeAndStrikethroughWholeString() {
        // Given
        let code = MarkStyleAction.keyboard(true)
        let strikethrough = MarkStyleAction.strikethrough(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            code,
            range: range
        )
        sut.apply(
            strikethrough,
            range: range
        )
        
        // Then
        let hasCode = sut.attributedString.isCodeFontInWhole(range: range)
        let hasStrikethrough = sut.attributedString.isEverySymbol(
            in: range,
            has: .strikethroughStyle
        )
        
        XCTAssertTrue(hasCode)
        XCTAssertTrue(hasStrikethrough)
    }
    
    func testBoldItalicCodeStrikethroughMarkupsToWholeString() {
        // Given
        let code = MarkStyleAction.keyboard(true)
        let strikethrough = MarkStyleAction.strikethrough(true)
        let bold = MarkStyleAction.bold(true)
        let italic = MarkStyleAction.italic(true)
        let range = NSRange(
            location: 0,
            length: sut.attributedString.length
        )
        
        // When
        sut.apply(
            code,
            range: range
        )
        sut.apply(
            strikethrough,
            range: range
        )
        sut.apply(
            bold,
            range: range
        )
        sut.apply(
            italic,
            range: range
        )
        
        // Then
        let hasCode = sut.attributedString.isCodeFontInWhole(range: range)
        let hasStrikethrough = sut.attributedString.isEverySymbol(
            in: range,
            has: .strikethroughStyle
        )
        let hasBold = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitBold
        )
        let hasItalic = sut.attributedString.isFontInWhole(
            range: range,
            has: .traitItalic
        )
        
        XCTAssertTrue(hasCode)
        XCTAssertTrue(hasStrikethrough)
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasItalic)
    }
    
    // MARK: Overlapping
    
    func testBoldAndItalicOverlapping() {
        // Given
        let bold = MarkStyleAction.bold(true)
        let italic = MarkStyleAction.italic(true)
        let boldRange = NSRange(
            location: 2,
            length: 5
        )
        let italicRange = NSRange(
            location: 3,
            length: 7
        )
        
        if !sut.attributedString.isRangeValid(boldRange) ||
            !sut.attributedString.isRangeValid(italicRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            bold,
            range: boldRange
        )
        sut.apply(
            italic,
            range: italicRange
        )
        
        // Then
        let hasBold = sut.attributedString.isFontInWhole(
            range: boldRange,
            has: .traitBold
        )
        let hasItalic = sut.attributedString.isFontInWhole(
            range: italicRange,
            has: .traitItalic
        )
        
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasItalic)
    }
    
    func testBoldAndCodeOverlapping() {
        // Given
        let bold = MarkStyleAction.bold(true)
        let code = MarkStyleAction.keyboard(true)
        let boldRange = NSRange(
            location: 2,
            length: 5
        )
        let codeRange = NSRange(
            location: 3,
            length: 7
        )
        
        if !sut.attributedString.isRangeValid(boldRange) ||
            !sut.attributedString.isRangeValid(codeRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            bold,
            range: boldRange
        )
        sut.apply(
            code,
            range: codeRange
        )
        
        // Then
        let hasBold = sut.attributedString.isFontInWhole(
            range: boldRange,
            has: .traitBold
        )
        let hasCode = sut.attributedString.isCodeFontInWhole(range: codeRange)
        
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasCode)
    }
    
    func testBoldAndStrikethroughOverlapping() {
        // Given
        let bold = MarkStyleAction.bold(true)
        let strikethrough = MarkStyleAction.strikethrough(true)
        let boldRange = NSRange(
            location: 2,
            length: 5
        )
        let strikethroughRange = NSRange(
            location: 3,
            length: 7
        )
        
        if !sut.attributedString.isRangeValid(boldRange) ||
            !sut.attributedString.isRangeValid(strikethroughRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            bold,
            range: boldRange
        )
        sut.apply(
            strikethrough,
            range: strikethroughRange
        )
        
        // Then
        let hasBold = sut.attributedString.isFontInWhole(
            range: boldRange,
            has: .traitBold
        )
        let hasStrikethrough = sut.attributedString.isEverySymbol(
            in: strikethroughRange,
            has: .strikethroughStyle
        )
        
        XCTAssertTrue(hasBold)
        XCTAssertTrue(hasStrikethrough)
    }
    
    func testItalicAndCodeOverlapping() {
        // Given
        let code = MarkStyleAction.keyboard(true)
        let italic = MarkStyleAction.italic(true)
        let codeRange = NSRange(
            location: 2,
            length: 5
        )
        let italicRange = NSRange(
            location: 3,
            length: 7
        )
        
        if !sut.attributedString.isRangeValid(codeRange) ||
            !sut.attributedString.isRangeValid(italicRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            code,
            range: codeRange
        )
        sut.apply(
            italic,
            range: italicRange
        )
        
        // Then
        let hasCode = sut.attributedString.isCodeFontInWhole(range: codeRange)
        let hasItalic = sut.attributedString.isFontInWhole(
            range: italicRange,
            has: .traitItalic
        )
        
        XCTAssertTrue(hasCode)
        XCTAssertTrue(hasItalic)
    }
    
    func testItalicAndStrikethroughOverlapping() {
        // Given
        let italic = MarkStyleAction.italic(true)
        let strikethrough = MarkStyleAction.strikethrough(true)
        let italicRange = NSRange(
            location: 2,
            length: 5
        )
        let strikethroughRange = NSRange(
            location: 3,
            length: 7
        )
        
        if !sut.attributedString.isRangeValid(italicRange) ||
            !sut.attributedString.isRangeValid(strikethroughRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            italic,
            range: italicRange
        )
        sut.apply(
            strikethrough,
            range: strikethroughRange
        )
        
        // Then
        let hasItalic = sut.attributedString.isFontInWhole(
            range: italicRange,
            has: .traitItalic
        )
        let hasStrikethrough = sut.attributedString.isEverySymbol(
            in: strikethroughRange,
            has: .strikethroughStyle
        )
        
        XCTAssertTrue(hasItalic)
        XCTAssertTrue(hasStrikethrough)
    }
    
    func testStrikethroughAndCodeOverlapping() {
        // Given
        let strikethrough = MarkStyleAction.strikethrough(true)
        let code = MarkStyleAction.keyboard(true)
        let strikethroughRange = NSRange(
            location: 2,
            length: 5
        )
        let codeRange = NSRange(
            location: 3,
            length: 7
        )
        
        if !sut.attributedString.isRangeValid(strikethroughRange) ||
            !sut.attributedString.isRangeValid(codeRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            strikethrough,
            range: strikethroughRange
        )
        sut.apply(
            code,
            range: codeRange
        )
        
        // Then
        let hasCode = sut.attributedString.isCodeFontInWhole(range: codeRange)
        let hasStrikethrough = sut.attributedString.isEverySymbol(
            in: strikethroughRange,
            has: .strikethroughStyle
        )
        
        XCTAssertTrue(hasCode)
        XCTAssertTrue(hasStrikethrough)
    }
    
    // MARK: Markup then Mention
    
    func testBoldMarkupAndThenMention() {
        // Given
        let markup = MarkStyleAction.bold(true)
        let boldRange = NSRange(location: 3, length: 10)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 4, length: 4)
        
        if !sut.attributedString.isRangeValid(boldRange) ||
            !sut.attributedString.isRangeValid(mentionRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        //When
        sut.apply(
            markup,
            range: boldRange
        )
        sut.apply(
            mention,
            range: mentionRange
        )
        
        //Then
        let hasMarkup = sut.attributedString.isFontInWhole(
            range: boldRange,
            has: .traitBold
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testItalicMarkupAndThenMention() {
        // Given
        let markup = MarkStyleAction.italic(true)
        let italicRange = NSRange(location: 3, length: 10)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 4, length: 4)
        
        if !sut.attributedString.isRangeValid(italicRange) ||
            !sut.attributedString.isRangeValid(mentionRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        //When
        sut.apply(
            markup,
            range: italicRange
        )
        sut.apply(
            mention,
            range: mentionRange
        )
        
        //Then
        let hasMarkup = sut.attributedString.isFontInWhole(
            range: italicRange,
            has: .traitItalic
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testCodeMarkupAndThenMention() {
        // Given
        let markup = MarkStyleAction.keyboard(true)
        let codeRange = NSRange(location: 3, length: 10)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 4, length: 4)
        
        if !sut.attributedString.isRangeValid(codeRange) ||
            !sut.attributedString.isRangeValid(mentionRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        //When
        sut.apply(
            markup,
            range: codeRange
        )
        sut.apply(
            mention,
            range: mentionRange
        )
        
        //Then
        let hasMarkup = sut.attributedString.isCodeFontInWhole(range: codeRange)
        XCTAssertTrue(hasMarkup)
    }
    
    func testStrikethroughMarkupAndThenMention() {
        // Given
        let markup = MarkStyleAction.strikethrough(true)
        let strikethroughRange = NSRange(location: 3, length: 10)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 4, length: 4)
        
        if !sut.attributedString.isRangeValid(strikethroughRange) ||
            !sut.attributedString.isRangeValid(mentionRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        //When
        sut.apply(
            markup,
            range: strikethroughRange
        )
        sut.apply(
            mention,
            range: mentionRange
        )
        
        //Then
        let hasMarkup = sut.attributedString.isEverySymbol(
            in: strikethroughRange,
            has: .strikethroughStyle
        )
        XCTAssertTrue(hasMarkup)
    }
    
    // MARK: Mention then Markup
    
    func testInsertMentionAndThenApplyBold() {
        // Given
        let markup = MarkStyleAction.bold(true)
        let markupRange = NSRange(location: 4, length: 8)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 5, length: 5)
        
        if !sut.attributedString.isRangeValid(mentionRange) ||
            !sut.attributedString.isRangeValid(markupRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            mention,
            range: mentionRange
        )
        sut.apply(
            markup,
            range: markupRange
        )
        
        // Then
        let hasMarkup = sut.attributedString.isFontInWhole(
            range: markupRange,
            has: .traitBold
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testInsertMentionAndThenApplyItalic() {
        // Given
        let markup = MarkStyleAction.italic(true)
        let markupRange = NSRange(location: 4, length: 8)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 5, length: 5)
        
        if !sut.attributedString.isRangeValid(mentionRange) ||
            !sut.attributedString.isRangeValid(markupRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            mention,
            range: mentionRange
        )
        sut.apply(
            markup,
            range: markupRange
        )
        
        // Then
        let hasMarkup = sut.attributedString.isFontInWhole(
            range: markupRange,
            has: .traitItalic
        )
        XCTAssertTrue(hasMarkup)
    }
    
    func testInsertMentionAndThenApplyCode() {
        // Given
        let markup = MarkStyleAction.keyboard(true)
        let markupRange = NSRange(location: 4, length: 8)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 5, length: 5)
        
        if !sut.attributedString.isRangeValid(mentionRange) ||
            !sut.attributedString.isRangeValid(markupRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            mention,
            range: mentionRange
        )
        sut.apply(
            markup,
            range: markupRange
        )
        
        // Then
        let hasMarkup = sut.attributedString.isCodeFontInWhole(range: markupRange)
        XCTAssertTrue(hasMarkup)
    }
    
    func testInsertMentionAndThenApplyStrikethrough() {
        // Given
        let markup = MarkStyleAction.strikethrough(true)
        let markupRange = NSRange(location: 4, length: 8)
        let mention = MarkStyleAction.mention("randomPage")
        let mentionRange = NSRange(location: 5, length: 5)
        
        if !sut.attributedString.isRangeValid(mentionRange) ||
            !sut.attributedString.isRangeValid(markupRange) {
            XCTFail("Ranges out of bounds")
            return
        }
        
        // When
        sut.apply(
            mention,
            range: mentionRange
        )
        sut.apply(
            markup,
            range: markupRange
        )
        
        // Then
        let hasMarkup = sut.attributedString.isEverySymbol(
            in: markupRange,
            has: .strikethroughStyle
        )
        XCTAssertTrue(hasMarkup)
    }
}
