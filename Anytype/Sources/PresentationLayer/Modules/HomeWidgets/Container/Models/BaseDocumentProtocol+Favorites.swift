import Foundation
import Services

extension BaseDocumentProtocol {

    /// Returns true if this document's widget tree contains a widget block referencing
    /// `objectId`. The semantic meaning is carried by the document the call is made on:
    ///  - Called on the per-user personal widgets document, it answers "is favorited".
    ///  - Called on the shared channel widgets document, it answers "is channel-pinned".
    /// Call-site variable names (`personalWidgetsObject` / `channelWidgetsObject`) make
    /// the intent explicit without needing separately-named wrappers.
    func containsWidgetFor(objectId: String) -> Bool {
        widgetBlockIdFor(targetObjectId: objectId) != nil
    }
}
