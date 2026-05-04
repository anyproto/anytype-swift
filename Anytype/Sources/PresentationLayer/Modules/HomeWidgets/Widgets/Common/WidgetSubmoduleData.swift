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
}
