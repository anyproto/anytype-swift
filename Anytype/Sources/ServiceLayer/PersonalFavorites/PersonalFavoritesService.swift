import Foundation
import Services
import AnytypeCore

protocol PersonalFavoritesServiceProtocol: AnyObject, Sendable {
    // Caller must pass an already-open `personalWidgetsObject`; synchronous reads
    // of `children` / `widgetBlockIdFor(...)` would otherwise duplicate on toggle.
    func toggle(objectId: String, personalWidgetsObject: any BaseDocumentProtocol) async throws
}

final class PersonalFavoritesService: PersonalFavoritesServiceProtocol {

    private let blockWidgetService: any BlockWidgetServiceProtocol = Container.shared.blockWidgetService()

    func toggle(objectId: String, personalWidgetsObject: any BaseDocumentProtocol) async throws {
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
