import Foundation
import Services

@MainActor
protocol WidgetObjectListMenuOutput: AnyObject, Sendable {
    func setFavorite(objectIds: [String], _ isFavorite: Bool)
    func setArchive(objectIds: [String], _ isArchived: Bool)
    func delete(objectIds: [String])
    func forceDelete(objectIds: [String])
}
