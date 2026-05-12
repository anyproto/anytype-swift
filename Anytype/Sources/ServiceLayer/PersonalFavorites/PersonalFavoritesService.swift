import Foundation
import Services
import AnytypeCore

protocol PersonalFavoritesServiceProtocol: AnyObject, Sendable {
    // Caller must pass an already-open `personalWidgetsObject`; synchronous reads
    // of `widgetBlockIdFor(...)` would otherwise duplicate on toggle.
    func toggle(objectId: String, personalWidgetsObject: any BaseDocumentProtocol) async throws
}

final class PersonalFavoritesService: PersonalFavoritesServiceProtocol {

    private let blockWidgetService: any BlockWidgetServiceProtocol = Container.shared.blockWidgetService()

    func toggle(objectId: String, personalWidgetsObject: any BaseDocumentProtocol) async throws {
        // `.innerFirst` mirrors desktop (`anyproto/anytype-ts#2161`) — wrappers must land at
        // the doc root, not nested inside `header`. With `.above(children.first?.id)` the
        // wrapper ended up under `header` and a later `BlockListMoveToExistingObject` reorder
        // misparented it back to root, triggering a consistency pass that deleted the other
        // favorite (IOS-6124).
        try await blockWidgetService.toggleWidgetBlock(
            contextId: personalWidgetsObject.objectId,
            targetObjectId: objectId,
            existingWidgetBlockId: personalWidgetsObject.widgetBlockIdFor(targetObjectId: objectId),
            position: .innerFirst,
            layout: .link,
            limit: 0
        )
    }
}
