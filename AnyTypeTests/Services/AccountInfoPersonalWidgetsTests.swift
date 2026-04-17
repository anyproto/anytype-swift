import Testing
import Services
@testable import Anytype

// Pins the `AccountInfo.personalWidgetsId` derivation contract
// (see `AccountInfo+PersonalWidgets.swift`): prefix `_personalWidgets_`
// concatenated with `accountSpaceId`, with dots replaced by underscores.
// Mirrors desktop `U.Object.getPersonalWidgetsId()` and middleware GO-6962.
struct AccountInfoPersonalWidgetsTests {

    @Test func simpleSpaceId() {
        #expect(makeInfo(spaceId: "bafyreiabc123").personalWidgetsId == "_personalWidgets_bafyreiabc123")
    }

    @Test func spaceIdWithOneDot() {
        #expect(makeInfo(spaceId: "bafyreiabc.123").personalWidgetsId == "_personalWidgets_bafyreiabc_123")
    }

    @Test func spaceIdWithMultipleDots() {
        #expect(makeInfo(spaceId: "a.b.c.d").personalWidgetsId == "_personalWidgets_a_b_c_d")
    }

    @Test func emptySpaceId() {
        #expect(makeInfo(spaceId: "").personalWidgetsId == "_personalWidgets_")
    }

    @Test func emptyAccountInfoMatches() {
        // Smoke-check the extension itself against the one canonical empty instance —
        // guards against the file being dropped from the Services target at all.
        #expect(AccountInfo.empty.personalWidgetsId == "_personalWidgets_")
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
