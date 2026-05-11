import Foundation
import SwiftUI
import Services

/// Pre-warmed dataview subscription bundle for Set/Type widgets, populated by the loader
/// before flipping the section gate so the widget renders rows on the first frame.
struct PrefetchedSetSubscription: Sendable {
    let setDocument: any SetDocumentProtocol
    let subscriptionStorage: any SubscriptionStorageProtocol
    /// Snapshot captured at pre-warm time; the VM seeds rows synchronously from this in init,
    /// then the live storage takes over on subsequent emits.
    let state: SubscriptionStorageState
}

/// Pre-warmed first-level child rows for expanded `(.tree, .page)` Object Tree widgets.
/// Pure data — no live storage handoff. The VM seeds `details` synchronously in `init`,
/// then its own `treeSubscriptionManager` starts a fresh live subscription on mount.
struct PrefetchedTreeChildren: Sendable {
    /// First-level children, sorted by parent `.links` order, already limited to `widgetInfo.fixedLimit`.
    let childDetails: [ObjectDetails]
}

/// Pre-warmed Unread rows; seeds `unreadItems` + `didLoadInitial` before live subscription takes over.
struct PrefetchedUnreadSection: Sendable {
    let rows: [UnreadSectionRowData]
    let supportsMultiChats: Bool
}

struct WidgetSubmoduleData {
    let widgetBlockId: String
    /// Shared channel widgets document (`info.widgetsId`) — holds pinned widgets
    /// visible to every member of the space.
    let channelWidgetsObject: any BaseDocumentProtocol
    /// Per-user personal widgets document (`info.personalWidgetsId`) — holds the
    /// current user's favorites.
    let personalWidgetsObject: any BaseDocumentProtocol
    let homeState: Binding<HomeWidgetsState>
    let spaceInfo: AccountInfo
    let output: (any CommonWidgetModuleOutput)?
    /// Pre-seeded object details for `.object`-source widgets, enabling synchronous first-render without an empty frame.
    let prefetchedDetails: ObjectDetails?
    /// Pre-warmed set subscription bundle for Set/Type widgets — see `PrefetchedSetSubscription`.
    let prefetchedSetSubscription: PrefetchedSetSubscription?
    /// Pre-warmed first-level children for Object Tree widgets — see `PrefetchedTreeChildren`.
    let prefetchedTreeChildren: PrefetchedTreeChildren?
}
