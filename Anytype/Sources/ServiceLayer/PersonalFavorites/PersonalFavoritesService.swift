import Foundation
import Services
import AnytypeCore

protocol PersonalFavoritesServiceProtocol: AnyObject, Sendable {
    /// Toggles the personal favorite state for the given object. If the object is
    /// already in the per-user personal widgets document, its widget block is
    /// removed; otherwise a new widget block is created at the top of the list.
    ///
    /// Caller must pass an already-open `personalWidgetsObject` — `children` and
    /// `widgetBlockIdFor(...)` are read synchronously, so a not-yet-opened doc would
    /// fall into the "create" branch on an existing favorite and produce a duplicate.
    func toggle(objectId: String, personalWidgetsObject: any BaseDocumentProtocol) async throws
}

final class PersonalFavoritesService: PersonalFavoritesServiceProtocol {

    private let blockWidgetService: any BlockWidgetServiceProtocol = Container.shared.blockWidgetService()

    func toggle(objectId: String, personalWidgetsObject: any BaseDocumentProtocol) async throws {
        // WidgetPosition mapping: desktop uses MW `InnerFirst` to prepend. iOS
        // `WidgetPosition` exposes `.end`, `.above`, `.below` only. The shared
        // `toggleWidgetBlock` helper reproduces "prepend to top" via `.above(first)`
        // with `.end` fallback for an empty document.
        try await blockWidgetService.toggleWidgetBlock(
            contextId: personalWidgetsObject.objectId,
            targetObjectId: objectId,
            existingWidgetBlockId: personalWidgetsObject.widgetBlockIdFor(targetObjectId: objectId),
            firstChildBlockId: personalWidgetsObject.children.first?.id,
            layout: .link,
            limit: 0
        )
    }
}
