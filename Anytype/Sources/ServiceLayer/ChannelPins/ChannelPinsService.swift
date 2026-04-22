import Foundation
import Services

protocol ChannelPinsServiceProtocol: AnyObject, Sendable {
    /// Toggles the channel pin state for the given object against the shared channel
    /// widgets document (`info.widgetsId`). If `objectId` already has a widget block
    /// in `channelWidgetsObject`, it is removed; otherwise a new widget block is
    /// created at the top of the list using the provided `layout` / `limit`.
    ///
    /// Caller must pass an already-open `channelWidgetsObject` — `children` and
    /// `widgetBlockIdFor(...)` are read synchronously, so a not-yet-opened doc would
    /// fall into the "create" branch on an existing pin and produce a duplicate.
    func toggle(
        objectId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        layout: BlockWidget.Layout,
        limit: Int
    ) async throws
}

final class ChannelPinsService: ChannelPinsServiceProtocol {

    private let blockWidgetService: any BlockWidgetServiceProtocol = Container.shared.blockWidgetService()

    func toggle(
        objectId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        layout: BlockWidget.Layout,
        limit: Int
    ) async throws {
        try await blockWidgetService.toggleWidgetBlock(
            contextId: channelWidgetsObject.objectId,
            targetObjectId: objectId,
            existingWidgetBlockId: channelWidgetsObject.widgetBlockIdFor(targetObjectId: objectId),
            firstChildBlockId: channelWidgetsObject.children.first?.id,
            layout: layout,
            limit: limit
        )
    }
}
