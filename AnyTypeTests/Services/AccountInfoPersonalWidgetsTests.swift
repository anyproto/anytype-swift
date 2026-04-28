import Testing
import Services
@testable import Anytype

// Pins the `AccountInfo.personalWidgetsId` derivation contract
// (see `AccountInfo+PersonalWidgets.swift`). Must stay in lock-step with
// anytype-heart `domain.NewPersonalWidgetsId` (GO-6962): only the FIRST dot
// in the spaceId is replaced with `_`, so the middleware's `ParsePersonalWidgetsId`
// can split on the first underscore and reconstruct the original spaceId.
struct AccountInfoPersonalWidgetsTests {

    @Test func spaceIdWithOneDot_replacesDot() {
        // Typical anytype spaceId shape (one dot). Round-trips through the MW parser.
        #expect(makeInfo(spaceId: "bafyreiabc.123").personalWidgetsId == "_personalWidgets_bafyreiabc_123")
    }

    @Test func spaceIdWithMultipleDots_replacesOnlyFirstDot() {
        // Mirrors `strings.Replace(spaceId, ".", "_", 1)` on the MW side. Replacing
        // every dot would over-encode and break MW round-trip for 2+ dot spaceIds.
        #expect(makeInfo(spaceId: "a.b.c.d").personalWidgetsId == "_personalWidgets_a_b.c.d")
    }

    @Test func spaceIdWithoutDot_leftAsIs() {
        // No-dot spaceId is rejected by the MW parser ("no underscore"). The iOS
        // helper still forms the string verbatim — guarding the inputs is the
        // caller's responsibility, not the encoder's.
        #expect(makeInfo(spaceId: "bafyreiabc123").personalWidgetsId == "_personalWidgets_bafyreiabc123")
    }

    @Test func emptySpaceId_returnsEmptyAndAsserts() {
        // Empty accountSpaceId is a programmer error: callers must wait for the
        // account info to be populated. The helper logs an assertion and returns
        // an empty string so we never ship `_personalWidgets_` to the middleware,
        // which silently fails ObjectOpen.
        #expect(makeInfo(spaceId: "").personalWidgetsId == "")
    }

    @Test func emptyAccountInfo_returnsEmptyAndAsserts() {
        #expect(AccountInfo.empty.personalWidgetsId == "")
    }

    private func makeInfo(spaceId: String) -> AccountInfo {
        AccountInfo(
            homeObjectID: "",
            archiveObjectID: "",
            profileObjectID: "",
            gatewayURL: "",
            accountSpaceId: spaceId,
            spaceViewId: "",
            widgetsId: "",
            analyticsId: "",
            deviceId: "",
            networkId: "",
            techSpaceId: "",
            ethereumAddress: "",
            spaceChatId: "",
            metadataKey: ""
        )
    }
}
