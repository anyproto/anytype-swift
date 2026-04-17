import Foundation
import Services
import AnytypeCore

// Why this lives in the app target, not `Modules/Services/`:
// The plan's notes ask the service to use `OpenedDocumentsProviderProtocol` to
// resolve the per-space personal widgets document. That protocol is declared
// `internal` in the Anytype app target (see `OpenedDocumentsProvider.swift`)
// and is not visible to `Modules/Services`. The pragmatic placement is
// alongside other app-target services (e.g. `ChatActionService`,
// `PinnedSubscriptionService`) that also depend on app-only collaborators.
// Registration still happens in `Anytype/Sources/ServiceLayer/ServicesDI.swift`
// using the same `Factory` pattern used for `BlockWidgetService` registration.

protocol PersonalFavoritesServiceProtocol: AnyObject, Sendable {
    /// Toggles the personal favorite state for the given object by consulting the
    /// personal widgets document. If a widget block already references `objectId`
    /// it is removed; otherwise a new widget block is created at the top of the
    /// personal widgets list.
    func toggle(objectId: String, accountInfo: AccountInfo) async throws

    /// Adds the given object to the per-user personal favorites list.
    /// Prepends a new widget block so the newest favorite sits at the top —
    /// same ordering desktop uses via `InnerFirst`.
    func addToFavorites(objectId: String, accountInfo: AccountInfo) async throws

    /// Removes the widget block with `widgetBlockId` from the personal widgets
    /// document. The caller resolves the block id via
    /// `BaseDocumentProtocol.widgetBlockIdFor(targetObjectId:)` before calling.
    func removeFromFavorites(widgetBlockId: String, accountInfo: AccountInfo) async throws
}

final class PersonalFavoritesService: PersonalFavoritesServiceProtocol {

    private let blockWidgetService: any BlockWidgetServiceProtocol = Container.shared.blockWidgetService()
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    func toggle(objectId: String, accountInfo: AccountInfo) async throws {
        let document = documentService.document(
            objectId: accountInfo.personalWidgetsId,
            spaceId: accountInfo.accountSpaceId
        )
        if let widgetBlockId = document.widgetBlockIdFor(targetObjectId: objectId) {
            try await removeFromFavorites(widgetBlockId: widgetBlockId, accountInfo: accountInfo)
        } else {
            try await addToFavorites(objectId: objectId, accountInfo: accountInfo)
        }
    }

    func addToFavorites(objectId: String, accountInfo: AccountInfo) async throws {
        let document = documentService.document(
            objectId: accountInfo.personalWidgetsId,
            spaceId: accountInfo.accountSpaceId
        )
        // WidgetPosition enum mapping note (plan Open Question #2): desktop documents
        // use MW `InnerFirst` to prepend. The iOS `WidgetPosition` enum exposes
        // `.end`, `.above`, `.below` but not a direct `.innerFirst`/`.start` case.
        // We reproduce "prepend to top" with the same pattern `ObjectSettingsViewModel`
        // uses for channel pins: `.above(first)` when the document has children,
        // `.end` otherwise. Middleware still re-links the new block as the first
        // child of the widgets container, so visual order matches desktop.
        let firstChildId = document.children.first?.id
        let position: WidgetPosition = firstChildId.map { .above(widgetId: $0) } ?? .end

        try await blockWidgetService.createWidgetBlock(
            contextId: accountInfo.personalWidgetsId,
            sourceId: objectId,
            layout: .link,
            limit: 0,
            position: position
        )
    }

    func removeFromFavorites(widgetBlockId: String, accountInfo: AccountInfo) async throws {
        try await blockWidgetService.removeWidgetBlock(
            contextId: accountInfo.personalWidgetsId,
            widgetBlockId: widgetBlockId
        )
    }
}

// Unit test note (IOS-5864 Task 3): no mock `BlockWidgetServiceProtocol` exists
// in `AnyTypeTests/` today, and `Modules/Services/Tests/` is not a configured
// target. Per the plan's pragmatic testing policy the toggle/add/remove
// behaviour is covered by the Task 15 simulator checklist (items 1, 6, 7)
// until mock infrastructure lands.
