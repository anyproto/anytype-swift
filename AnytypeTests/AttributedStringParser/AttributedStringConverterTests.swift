import XCTest
@testable import Anytype


final class AttributedStringConverterTests: XCTestCase {
    
    private var sut = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.self
    
    func testOneBoldMarkupConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssert(firstMark.type == .bold)
        XCTAssert(firstMark.range.from == boldRange.location)
        XCTAssert(firstMark.range.to == boldRange.location + boldRange.length)
    }
    
    func testOneItalicMarkupConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssert(firstMark.type == .italic)
        XCTAssert(firstMark.range.from == italicRange.location)
        XCTAssert(firstMark.range.to == italicRange.location + italicRange.length)
    }
    
    func testOneCodeMarkupConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssert(firstMark.type == .keyboard)
        XCTAssert(firstMark.range.from == codeRange.location)
        XCTAssert(firstMark.range.to == codeRange.location + codeRange.length)
    }
    
    func testOneStrikethroughMarkupConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 1)
        guard let firstMark = middleMarks.first else {
            return
        }
        XCTAssert(firstMark.type == .strikethrough)
        XCTAssert(firstMark.range.from == strikethroughRange.location)
        XCTAssert(firstMark.range.to == strikethroughRange.location + strikethroughRange.length)
    }
    
    func testTwoSeparateBoldMarkupsConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssert(firstMark.type == .bold)
        XCTAssert(firstMark.range.from == firstRange.location)
        XCTAssert(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssert(lastMark.type == .bold)
        XCTAssert(lastMark.range.from == secondRange.location)
        XCTAssert(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testTwoSeparateItalicMarkupsConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssert(firstMark.type == .italic)
        XCTAssert(firstMark.range.from == firstRange.location)
        XCTAssert(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssert(lastMark.type == .italic)
        XCTAssert(lastMark.range.from == secondRange.location)
        XCTAssert(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testTwoSeparateCodeMarkupsConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssert(firstMark.type == .keyboard)
        XCTAssert(firstMark.range.from == firstRange.location)
        XCTAssert(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssert(lastMark.type == .keyboard)
        XCTAssert(lastMark.range.from == secondRange.location)
        XCTAssert(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testTwoSeparateStrikethroughMarkupsConvertation() {
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
        let middleMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middleMarks.count == 2)
        guard let firstMark = middleMarks.first,
              let lastMark = middleMarks.last else {
            return
        }
        XCTAssert(firstMark.type == .strikethrough)
        XCTAssert(firstMark.range.from == firstRange.location)
        XCTAssert(firstMark.range.to == firstRange.location + firstRange.length)
     
        XCTAssert(lastMark.type == .strikethrough)
        XCTAssert(lastMark.range.from == secondRange.location)
        XCTAssert(lastMark.range.to == secondRange.location + secondRange.length)
    }
    
    func testThreeBoldMarkupsJoinInOneConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssert(mark.type == .bold)
        XCTAssert(mark.range.from == firstRange.location)
        XCTAssert(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testThreeItalicMarkupsJoinInOneConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssert(mark.type == .italic)
        XCTAssert(mark.range.from == firstRange.location)
        XCTAssert(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testThreeCodeMarkupsJoinInOneConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssert(mark.type == .keyboard)
        XCTAssert(mark.range.from == firstRange.location)
        XCTAssert(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testThreeStrikethroughMarkupsJoinInOneConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssert(mark.type == .strikethrough)
        XCTAssert(mark.range.from == firstRange.location)
        XCTAssert(mark.range.to == thirdRange.location + thirdRange.length)
    }
    
    func testThreeStrikethroughMarkupsWithDifferentValuesConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 1)
        guard let mark = middlewareMarks.first else {
            return
        }
        XCTAssert(mark.type == .strikethrough)
        XCTAssert(mark.range.from == firstRange.location)
        XCTAssert(mark.range.to == firstRange.location + firstRange.length)
    }
    
    func testBoldAndCodeAndItalicNotJoiningToOneMarkConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 3)
        guard let boldMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .bold }),
              let italicMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .italic }),
              let codeMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .keyboard }) else {
            XCTFail("Unexpected mark types")
            return
        }
        XCTAssert(boldMark.type == .bold)
        XCTAssert(boldMark.range.from == boldRange.location)
        XCTAssert(boldMark.range.to == boldRange.location + boldRange.length)
        
        XCTAssert(codeMark.type == .keyboard)
        XCTAssert(codeMark.range.from == codeRange.location)
        XCTAssert(codeMark.range.to == codeRange.location + codeRange.length)
        
        XCTAssert(italicMark.type == .italic)
        XCTAssert(italicMark.range.from == italicRange.location)
        XCTAssert(italicMark.range.to == italicRange.location + italicRange.length)
    }
    
    func testCodeAndItalicAmdBoldNotJoiningToOneMarkConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 3)
        guard let boldMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .bold }),
              let italicMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .italic }),
              let codeMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .keyboard }) else {
            XCTFail("Unexpected mark types")
            return
        }
        XCTAssert(boldMark.type == .bold)
        XCTAssert(boldMark.range.from == boldRange.location)
        XCTAssert(boldMark.range.to == boldRange.location + boldRange.length)
        
        XCTAssert(codeMark.type == .keyboard)
        XCTAssert(codeMark.range.from == codeRange.location)
        XCTAssert(codeMark.range.to == codeRange.location + codeRange.length)
        
        XCTAssert(italicMark.type == .italic)
        XCTAssert(italicMark.range.from == italicRange.location)
        XCTAssert(italicMark.range.to == italicRange.location + italicRange.length)
    }
    
    func testBoldAndItalicAndCodeNotJoiningToOneMarkConvertion() {
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
        let middlewareMarks = sut.asMiddleware(attributedText: testString).marks.marks
        
        // Then
        XCTAssert(middlewareMarks.count == 3)
        guard let boldMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .bold }),
              let italicMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .italic }),
              let codeMark = middlewareMarks.first(where: { mark -> Bool in mark.type == .keyboard }) else {
            XCTFail("Unexpected mark types")
            return
        }
        XCTAssert(boldMark.type == .bold)
        XCTAssert(boldMark.range.from == boldRange.location)
        XCTAssert(boldMark.range.to == boldRange.location + boldRange.length)
        
        XCTAssert(codeMark.type == .keyboard)
        XCTAssert(codeMark.range.from == codeRange.location)
        XCTAssert(codeMark.range.to == codeRange.location + codeRange.length)
        
        XCTAssert(italicMark.type == .italic)
        XCTAssert(italicMark.range.from == italicRange.location)
        XCTAssert(italicMark.range.to == italicRange.location + italicRange.length)
    }
}
