import XCTest
@testable import Anytype


final class AttributedStringConverterTests: XCTestCase {
    
    private var attributedStringConverter: MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.Type!
    
    // MARK: Overriden methods
    
    override func setUp() {
        attributedStringConverter = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.self
    }
    
    override func tearDown() {
        attributedStringConverter = nil
    }
    
    // MARK: Tests
    
    func testConvertOneBoldMarkup() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let boldRange = NSRange(location: 3, length: 2)
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 22),
            range: boldRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssertTrue(firstMark.type == .bold)
        XCTAssertTrue(firstMark.range.from == boldRange.location)
        XCTAssertTrue(firstMark.range.to == boldRange.location + boldRange.length)
    }
    
    func testConvertOneItalicMarkup() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let italicRange = NSRange(location: 3, length: 2)
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 22),
            range: italicRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssertTrue(firstMark.type == .italic)
        XCTAssertTrue(firstMark.range.from == italicRange.location)
        XCTAssertTrue(firstMark.range.to == italicRange.location + italicRange.length)
    }
    
    func testConvertOneCodeMarkup() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let codeRange = NSRange(location: 3, length: 2)
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: codeRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssertTrue(firstMark.type == .keyboard)
        XCTAssertTrue(firstMark.range.from == codeRange.location)
        XCTAssertTrue(firstMark.range.to == codeRange.location + codeRange.length)
    }
    
    func testConvertOneStrikethroughMarkup() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let strikethroughRange = NSRange(location: 3, length: 2)
        
        // When
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: strikethroughRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssertTrue(firstMark.type == .strikethrough)
        XCTAssertTrue(firstMark.range.from == strikethroughRange.location)
        XCTAssertTrue(firstMark.range.to == strikethroughRange.location + strikethroughRange.length)
    }
    
    func testConvertTwoSeparateBoldMarkups() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(location: 5, length: 3)
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 44),
            range: firstRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 44),
            range: secondRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssertTrue(firstMark.type == .bold)
        XCTAssertTrue(firstMark.range.from == firstRange.location)
        XCTAssertTrue(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssertTrue(lastMark.type == .bold)
        XCTAssertTrue(lastMark.range.from == secondRange.location)
        XCTAssertTrue(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testConvertTwoSeparateItalicMarkups() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(location: 5, length: 3)
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 44),
            range: firstRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 44),
            range: secondRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssertTrue(firstMark.type == .italic)
        XCTAssertTrue(firstMark.range.from == firstRange.location)
        XCTAssertTrue(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssertTrue(lastMark.type == .italic)
        XCTAssertTrue(lastMark.range.from == secondRange.location)
        XCTAssertTrue(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testConvertTwoSeparateCodeMarkups() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(location: 5, length: 3)
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: firstRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: secondRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssertTrue(firstMark.type == .keyboard)
        XCTAssertTrue(firstMark.range.from == firstRange.location)
        XCTAssertTrue(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssertTrue(lastMark.type == .keyboard)
        XCTAssertTrue(lastMark.range.from == secondRange.location)
        XCTAssertTrue(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testConvertTwoSeparateStrikethroughMarkups() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(location: 5, length: 3)
        
        // When
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: firstRange
        )
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: secondRange
        )
        let middleMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssertTrue(firstMark.type == .strikethrough)
        XCTAssertTrue(firstMark.range.from == firstRange.location)
        XCTAssertTrue(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssertTrue(lastMark.type == .strikethrough)
        XCTAssertTrue(lastMark.range.from == secondRange.location)
        XCTAssertTrue(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testThatThreeNighboringBoldMarkupsConvertToOne() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(
            location: firstRange.location + firstRange.length,
            length: 3
        )
        let thirdRange = NSRange(
            location: secondRange.location + secondRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 33),
            range: firstRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 22),
            range: secondRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 11),
            range: thirdRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssertTrue(mark.type == .bold)
        XCTAssertTrue(mark.range.from == firstRange.location)
        XCTAssertTrue(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testThatThreeNighboringItalicMarkupsConvertToOne() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(
            location: firstRange.location + firstRange.length,
            length: 3
        )
        let thirdRange = NSRange(
            location: secondRange.location + secondRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 33),
            range: firstRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 22),
            range: secondRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 11),
            range: thirdRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssertTrue(mark.type == .italic)
        XCTAssertTrue(mark.range.from == firstRange.location)
        XCTAssertTrue(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testThatThreeNighboringCodeMarkupsConvertToOne() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(
            location: firstRange.location + firstRange.length,
            length: 3
        )
        let thirdRange = NSRange(
            location: secondRange.location + secondRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: firstRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: secondRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: thirdRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssertTrue(mark.type == .keyboard)
        XCTAssertTrue(mark.range.from == firstRange.location)
        XCTAssertTrue(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testThatThreeNighboringStrikethroughMarkupsConvertToOne() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(
            location: firstRange.location + firstRange.length,
            length: 3
        )
        let thirdRange = NSRange(
            location: secondRange.location + secondRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: firstRange
        )
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: secondRange
        )
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: thirdRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssertTrue(mark.type == .strikethrough)
        XCTAssertTrue(mark.range.from == firstRange.location)
        XCTAssertTrue(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testConvertThreeStrikethroughMarkupsWithDifferentValues() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let firstRange = NSRange(location: 2, length: 2)
        let secondRange = NSRange(
            location: firstRange.location + firstRange.length,
            length: 3
        )
        let thirdRange = NSRange(
            location: secondRange.location + secondRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: firstRange
        )
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.double.rawValue,
            range: secondRange
        )
        testString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.patternDot.rawValue,
            range: thirdRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssertTrue(mark.type == .strikethrough)
        XCTAssertTrue(mark.range.from == firstRange.location)
        XCTAssertTrue(mark.range.to == firstRange.location + firstRange.length)
    }
    
    func testNotConvertBoldCodeItalicMarksupsIntoOne() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let boldRange = NSRange(location: 2, length: 2)
        let codeRange = NSRange(
            location: boldRange.location + boldRange.length,
            length: 3
        )
        let italicRange = NSRange(
            location: codeRange.location + codeRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 33),
            range: boldRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: codeRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 55),
            range: italicRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 3)
        guard let boldMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .bold }),
              let italicMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .italic }),
              let codeMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .keyboard }) else {
            XCTFail("Unexpected mark types")
            return
        }
        XCTAssertTrue(boldMark.type == .bold)
        XCTAssertTrue(boldMark.range.from == boldRange.location)
        XCTAssertTrue(boldMark.range.to == boldRange.location + boldRange.length)
        
        XCTAssertTrue(codeMark.type == .keyboard)
        XCTAssertTrue(codeMark.range.from == codeRange.location)
        XCTAssertTrue(codeMark.range.to == codeRange.location + codeRange.length)
        
        XCTAssertTrue(italicMark.type == .italic)
        XCTAssertTrue(italicMark.range.from == italicRange.location)
        XCTAssertTrue(italicMark.range.to == italicRange.location + italicRange.length)
    }
    
    func testNotConvertCodeItalicBoldMarksupsIntoOne() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let codeRange = NSRange(location: 2, length: 2)
        let italicRange = NSRange(
            location: codeRange.location + codeRange.length,
            length: 3
        )
        let boldRange = NSRange(
            location: italicRange.location + italicRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 33),
            range: boldRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: codeRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 55),
            range: italicRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 3)
        guard let boldMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .bold }),
              let italicMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .italic }),
              let codeMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .keyboard }) else {
            XCTFail("Unexpected mark types")
            return
        }
        XCTAssertTrue(boldMark.type == .bold)
        XCTAssertTrue(boldMark.range.from == boldRange.location)
        XCTAssertTrue(boldMark.range.to == boldRange.location + boldRange.length)
        
        XCTAssertTrue(codeMark.type == .keyboard)
        XCTAssertTrue(codeMark.range.from == codeRange.location)
        XCTAssertTrue(codeMark.range.to == codeRange.location + codeRange.length)
        
        XCTAssertTrue(italicMark.type == .italic)
        XCTAssertTrue(italicMark.range.from == italicRange.location)
        XCTAssertTrue(italicMark.range.to == italicRange.location + italicRange.length)
    }
    
    func testNotConvertBoldItalicCodeMarksupsIntoOne() {
        // Given
        let testString = NSMutableAttributedString(
            string: "aaaaaaaaaaaaaaaaaaaa",
            attributes: [.font: UIFont.body]
        )
        let boldRange = NSRange(location: 2, length: 2)
        let italicRange = NSRange(
            location: boldRange.location + boldRange.length,
            length: 3
        )
        let codeRange = NSRange(
            location: italicRange.location + italicRange.length,
            length: 4
        )
        
        // When
        testString.addAttribute(
            .font,
            value: UIFont.boldSystemFont(ofSize: 33),
            range: boldRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.code,
            range: codeRange
        )
        testString.addAttribute(
            .font,
            value: UIFont.italicSystemFont(ofSize: 55),
            range: italicRange
        )
        let middlewareMarks = attributedStringConverter.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssertTrue(middlewareMarks.count == 3)
        guard let boldMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .bold }),
              let italicMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .italic }),
              let codeMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .keyboard }) else {
            XCTFail("Unexpected mark types")
            return
        }
        XCTAssertTrue(boldMark.type == .bold)
        XCTAssertTrue(boldMark.range.from == boldRange.location)
        XCTAssertTrue(boldMark.range.to == boldRange.location + boldRange.length)
        
        XCTAssertTrue(codeMark.type == .keyboard)
        XCTAssertTrue(codeMark.range.from == codeRange.location)
        XCTAssertTrue(codeMark.range.to == codeRange.location + codeRange.length)
        
        XCTAssertTrue(italicMark.type == .italic)
        XCTAssertTrue(italicMark.range.from == italicRange.location)
        XCTAssertTrue(italicMark.range.to == italicRange.location + italicRange.length)
    }
}
