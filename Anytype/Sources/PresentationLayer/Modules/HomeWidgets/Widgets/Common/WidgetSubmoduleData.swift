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
}
