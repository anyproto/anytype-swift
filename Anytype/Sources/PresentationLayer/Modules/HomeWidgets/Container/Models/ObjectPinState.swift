import Foundation

/// Combined view of an object's presence in the two independent widget lists
/// introduced by IOS-5864 Personal Favorites:
/// - `isFavorited`: object is in the current user's personal favorites
///   (virtual widget object at `accountInfo.personalWidgetsId`).
/// - `isPinnedToChannel`: object is in the shared channel pins
///   (widget tree on the channel's `widgetsId` document).
///
/// Passed as a single value through menu builders (object "⋯" menu + widget
/// long-press menu) to avoid parameter-pair churn across call sites.
struct ObjectPinState: Equatable {
    let isFavorited: Bool
    let isPinnedToChannel: Bool
}
