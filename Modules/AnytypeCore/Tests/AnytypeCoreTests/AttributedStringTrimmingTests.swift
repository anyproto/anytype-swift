@testable import AnytypeCore
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
    
    @Test
    func testTrimmingNewLines() {
        let str = AttributedString("\n\n\n1\n\n\n")
        let result = str.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let extected = AttributedString("1")
        
        #expect(result == extected)
    }
    
    @Test
    func testTrimmingWihtesapcesAndNewLines() {
        let str = AttributedString("    \n\n\n1\n\n     \n ")
        let result = str.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let extected = AttributedString("1")
        
        #expect(result == extected)
    }
}
