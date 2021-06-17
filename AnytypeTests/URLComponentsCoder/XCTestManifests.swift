import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
//        testCase(URLComponentsCoderTests.allTests),
        testCase(DecodingTests.allTests),
        testCase(EncodingTests.allTests)
    ]
}
#endif
