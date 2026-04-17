import Foundation
import Services
import AnytypeCore

protocol PersonalFavoritesServiceProtocol: AnyObject, Sendable {
    /// Toggles the personal favorite state for the given object. If the object is
    /// already in the per-user personal widgets document, its widget block is
    /// removed; otherwise a new widget block is created at the top of the list.
    func toggle(objectId: String, accountInfo: AccountInfo) async throws
}

final class PersonalFavoritesService: PersonalFavoritesServiceProtocol {

    private let blockWidgetService: any BlockWidgetServiceProtocol = Container.shared.blockWidgetService()
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    func toggle(objectId: String, accountInfo: AccountInfo) async throws {
        // WidgetPosition mapping: desktop uses MW `InnerFirst` to prepend. iOS
        // `WidgetPosition` exposes `.end`, `.above`, `.below` only. The shared
        // `toggleWidgetBlock` helper reproduces "prepend to top" via `.above(first)`
        // with `.end` fallback for an empty document.
        let document = documentService.document(
            objectId: accountInfo.personalWidgetsId,
            spaceId: accountInfo.accountSpaceId
        )
        // OpenedDocumentsProvider fires `document.open()` in a detached Task and
        // returns synchronously, so `children` / `widgetBlockIdFor` may still be
        // empty here. Await open explicitly before the read to avoid a race
        // where an existing favorite reads as absent and we fall into the create
        // branch, producing a duplicate widget block. `open()` is idempotent:
        // it early-exits when already opened and re-uses the in-flight task.
        try await document.open()
        try await blockWidgetService.toggleWidgetBlock(
            contextId: accountInfo.personalWidgetsId,
            targetObjectId: objectId,
            existingWidgetBlockId: document.widgetBlockIdFor(targetObjectId: objectId),
            firstChildBlockId: document.children.first?.id,
            layout: .link,
            limit: 0
        )
    }
}
