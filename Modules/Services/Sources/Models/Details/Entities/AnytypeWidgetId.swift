import Foundation

public enum AnytypeWidgetId: String, CaseIterable, Sendable {
    case pinned = "favorite"
    case chat = "chat"
    case allObjects = "allObjects"
    case recent = "recent"
    case recentOpen = "recentOpen"
    case bin = "bin"
}
