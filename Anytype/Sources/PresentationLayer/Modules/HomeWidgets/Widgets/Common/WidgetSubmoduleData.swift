import Foundation
import SwiftUI
import Services

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
    /// Already-resolved details for `.object`-source widgets, lifted from
    /// `BlockWidgetInfo` at dispatch time. Lets row VMs pre-seed name/icon
    /// synchronously instead of rendering empty until their own publisher ticks.
    let prefetchedDetails: ObjectDetails?
}
