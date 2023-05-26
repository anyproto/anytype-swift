import Foundation
import Services

protocol WidgetObjectListMenuOutput: AnyObject {
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool)
    func setArchive(objectIds: [BlockId], _ isArchived: Bool)
    func delete(objectIds: [BlockId])
    func forceDelete(objectIds: [BlockId])
}
