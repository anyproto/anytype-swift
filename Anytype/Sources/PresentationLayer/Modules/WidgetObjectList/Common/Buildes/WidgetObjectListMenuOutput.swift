import Foundation
import Services

@MainActor
protocol WidgetObjectListMenuOutput: AnyObject, Sendable {
    func setPin(objectIds: [String], _ isPinned: Bool)
    func setArchive(objectIds: [String], _ isArchived: Bool)
    func delete(objectIds: [String])
    func forceDelete(objectIds: [String])
}
