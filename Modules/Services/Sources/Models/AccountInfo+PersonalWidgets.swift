import Foundation

// Client-side derivation of the per-space personal widgets virtual object id.
// Mirrors desktop `U.Object.getPersonalWidgetsId()` and the middleware contract
// introduced by GO-6962 (anytype-heart PR #3092). Dots in the spaceId are
// replaced with underscores to keep the id safe to use as a document identifier.
//
// Unit test note: no `Modules/Services/Tests/` target exists and no precedent
// exists in `AnyTypeTests/` for pure-function tests against `AccountInfo`
// extensions, so per the plan's pragmatic testing policy the derivation is
// covered by manual simulator verification in Task 15 rather than a unit test.
public extension AccountInfo {
    var personalWidgetsId: String {
        "_personalWidgets_" + accountSpaceId.replacingOccurrences(of: ".", with: "_")
    }
}
