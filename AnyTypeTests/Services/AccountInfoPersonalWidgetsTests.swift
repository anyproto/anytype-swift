import Testing
import Services
@testable import Anytype

// Exercises the string derivation used by `AccountInfo.personalWidgetsId`
// (see `AccountInfo+PersonalWidgets.swift`). `AccountInfo` has no public init
// outside the proto bridge so we re-derive with the same rule here and pin the
// contract: dots in the spaceId become underscores, prefix is `_personalWidgets_`.
// Mirrors desktop `U.Object.getPersonalWidgetsId()` and middleware GO-6962.
struct AccountInfoPersonalWidgetsTests {

    @Test func simpleSpaceId() {
        #expect(derive("bafyreiabc123") == "_personalWidgets_bafyreiabc123")
    }

    @Test func spaceIdWithOneDot() {
        #expect(derive("bafyreiabc.123") == "_personalWidgets_bafyreiabc_123")
    }

    @Test func spaceIdWithMultipleDots() {
        #expect(derive("a.b.c.d") == "_personalWidgets_a_b_c_d")
    }

    @Test func emptySpaceId() {
        #expect(derive("") == "_personalWidgets_")
    }

    @Test func emptyAccountInfoMatches() {
        // Smoke-check the extension itself against the one available instance —
        // guards against the file being dropped from the Services target at all.
        #expect(AccountInfo.empty.personalWidgetsId == "_personalWidgets_")
    }

    private func derive(_ spaceId: String) -> String {
        "_personalWidgets_" + spaceId.replacingOccurrences(of: ".", with: "_")
    }
}
