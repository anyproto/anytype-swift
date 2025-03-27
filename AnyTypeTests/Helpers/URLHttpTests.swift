import Testing
import Foundation
@testable import Anytype

struct URLHttpTests {

    @Test(arguments: [
        (
            URL(string: "www.anytype.io")!,
            URL(string: "https://www.anytype.io")!,
            URL(string: "http://www.anytype.io")!
        ),
        (
            URL(string: "anytype.io")!,
            URL(string: "https://anytype.io")!,
            URL(string: "http://anytype.io")!
        ),
        (
            URL(string: "a.b.c.d.e.f")!,
            URL(string: "https://a.b.c.d.e.f")!,
            URL(string: "http://a.b.c.d.e.f")!
        ),
        (
            URL(string: "a.b.c.d.e.f/path-to?a=2")!,
            URL(string: "https://a.b.c.d.e.f/path-to?a=2")!,
            URL(string: "http://a.b.c.d.e.f/path-to?a=2")!
        )
    ])
    func testHttps(_ source: URL, _ https: URL, _ http: URL) async throws {
        #expect(source.urlByAddingHttpsIfSchemeIsEmpty() == https)
        #expect(source.urlByAddingHttpIfSchemeIsEmpty() == http)
    }
}
