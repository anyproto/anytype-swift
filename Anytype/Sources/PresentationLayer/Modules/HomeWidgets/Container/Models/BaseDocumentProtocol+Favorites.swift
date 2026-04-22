import Foundation
import Services

extension BaseDocumentProtocol {
    func containsWidgetFor(objectId: String) -> Bool {
        widgetBlockIdFor(targetObjectId: objectId) != nil
    }
}
