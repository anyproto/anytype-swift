import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

#if canImport(StoredHashMacroMacros)
import StoredHashMacroMacros

let testMacros: [String: Macro.Type] = [
    "StoredHash": StoredHashMacro.self
]
#endif

final class StoredHashTests: XCTestCase {
    func testStoredHashMacro() throws {
        #if canImport(StoredHashMacroMacros)
        assertMacroExpansion(
            """
            @StoredHash
            struct TestStruct: Hashable {
                var value1: Int
                var value2: String {
                    didSet { updateHash() }
                }
                let constantValue: Int
            }
            """,
            expandedSource: """
            struct TestStruct: Hashable {
                var value1: Int
                var value2: String {
                    didSet { updateHash() }
                }
                let constantValue: Int

                private var _lastHash: Int = 0

                private func computeHash() -> Int {
                    var hasher = Hasher()
                    hasher.combine(value1)
                    hasher.combine(value2)
                    hasher.combine(constantValue)
                    return hasher.finalize()
                }

                private mutating func updateHash() {
                    _lastHash = computeHash()
                }

                public func hash(into hasher: inout Hasher) {
                    hasher.combine(_lastHash)
                }

                public static func == (lhs: TestStruct, rhs: TestStruct) -> Bool {
                    lhs._lastHash == rhs._lastHash
                }

                public init(value1: Int, value2: String, constantValue: Int) {
                    self.value1 = value1
                    self.value2 = value2
                    self.constantValue = constantValue
                    self._lastHash = computeHash()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testStoredHashWithoutHashable() throws {
        #if canImport(StoredHashMacroMacros)
        assertMacroExpansion(
            """
            @StoredHash
            struct TestStruct {
                var value1: Int
                var value2: String
            }
            """,
            expandedSource: """
            struct TestStruct {
                var value1: Int
                var value2: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "message(\"Type must conform to Hashable protocol\")", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
