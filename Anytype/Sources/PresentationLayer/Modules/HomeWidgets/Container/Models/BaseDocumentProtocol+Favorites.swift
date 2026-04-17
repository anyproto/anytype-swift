import Foundation
import Services

// Both helpers below are identical wrappers over `widgetBlockIdFor(targetObjectId:)`.
// They are kept as separately-named methods because they operate on different
// `BaseDocumentProtocol` instances at the call sites:
//  - `isInMyFavorites` is called on the personal widgets document
//    (`accountInfo.personalWidgetsId`), representing the per-user CRDT favorites list.
//  - `isPinnedToChannel` is called on the channel widgets document
//    (`info.widgetsId`), representing the shared channel pins list.
// The distinct names document intent at the call site and prevent accidental
// cross-wiring of the two mechanisms.
//
// Test note: no unit test added. The underlying `widgetBlockIdFor` is exercised
// indirectly via the widgets screen manual verification (Task 15). A fake
// `BaseDocumentProtocol` exists in `AnyTypeTests/Markdown/Mocks/MockBaseDocument.swift`,
// but seeding widget-tree `children` + `infoContainer` link blocks for such a
// trivial wrapper would be more scaffolding than the helper warrants.
extension BaseDocumentProtocol {

    func isInMyFavorites(objectId: String) -> Bool {
        widgetBlockIdFor(targetObjectId: objectId) != nil
    }

    func isPinnedToChannel(objectId: String) -> Bool {
        widgetBlockIdFor(targetObjectId: objectId) != nil
    }
}
