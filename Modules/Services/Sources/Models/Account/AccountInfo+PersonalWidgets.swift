import Foundation
import AnytypeCore

// Client-side derivation of the per-space personal widgets virtual object id.
// Mirrors anytype-heart `domain.NewPersonalWidgetsId` (GO-6962, anytype-heart
// PR #3092): only the FIRST dot in the spaceId is replaced with `_`, so that
// `domain.ParsePersonalWidgetsId` can split the suffix on the first underscore
// and round-trip back to the original spaceId. Replacing every dot would diverge
// from middleware for any spaceId with 2+ dots.
//
// The spaceId encoded here is the user's ACTIVE data space (not the tech space).
// The heart resolver parses the spaceId straight out of the id and uses it as
// `domain.FullID.SpaceID` for the virtual object — see
// `anytype-heart/core/block/source/sourceimpl/service.go`.
public extension AccountInfo {
    var personalWidgetsId: String {
        guard !accountSpaceId.isEmpty else {
            // Dump the top of the call stack so we can identify the caller that
            // raced AccountManager initialization. Trimmed to keep the log readable.
            let stack = Thread.callStackSymbols.prefix(8).joined(separator: "\n")
            anytypeAssertionFailure(
                "personalWidgetsId requested with empty accountSpaceId\n\(stack)"
            )
            return ""
        }
        var encoded = accountSpaceId
        if let firstDot = encoded.firstIndex(of: ".") {
            encoded.replaceSubrange(firstDot...firstDot, with: "_")
        }
        return "_personalWidgets_" + encoded
    }
}
