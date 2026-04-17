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
        let document = documentService.document(
            objectId: accountInfo.personalWidgetsId,
            spaceId: accountInfo.accountSpaceId
        )
        if let widgetBlockId = document.widgetBlockIdFor(targetObjectId: objectId) {
            try await blockWidgetService.removeWidgetBlock(
                contextId: accountInfo.personalWidgetsId,
                widgetBlockId: widgetBlockId
            )
        } else {
            // WidgetPosition mapping: desktop uses MW `InnerFirst` to prepend. iOS
            // `WidgetPosition` exposes `.end`, `.above`, `.below` only. Reproduce
            // "prepend to top" via `.above(first)` with `.end` fallback for an
            // empty document — same pattern ObjectSettingsViewModel uses for channel pins.
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
    }
}
