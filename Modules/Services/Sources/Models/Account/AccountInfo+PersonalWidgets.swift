import Foundation
import AnytypeCore

public extension AccountInfo {
    // Mirrors anytype-heart `domain.NewPersonalWidgetsId`: only the first dot in
    // the spaceId is replaced so `ParsePersonalWidgetsId` can round-trip spaceIds
    // with multiple dots.
    var personalWidgetsId: String {
        guard !accountSpaceId.isEmpty else {
            anytypeAssertionFailure("personalWidgetsId requested with empty accountSpaceId")
            return ""
        }
        var encoded = accountSpaceId
        if let firstDot = encoded.firstIndex(of: ".") {
            encoded.replaceSubrange(firstDot...firstDot, with: "_")
        }
        return "_personalWidgets_" + encoded
    }
}
