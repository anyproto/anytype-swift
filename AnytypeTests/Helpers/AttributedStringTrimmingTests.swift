@testable import Anytype
import Testing
import Foundation

struct AttributedStringTrimmingTests {
    
    @Test
    func testTrimmingWhitespaces() {
        let str = AttributedString("   1   ")
        let result = str.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let extected = AttributedString("1")
        
        #expect(result == extected)
    }
}
