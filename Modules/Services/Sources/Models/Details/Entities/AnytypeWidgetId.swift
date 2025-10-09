import Foundation

public enum AnytypeWidgetId: String, CaseIterable, Sendable {
    case pinned = "favorite"
    case chat = "chat" // Delete aflter release 13
    case allObjects = "allObjects"
    case recent = "recent"
    case recentOpen = "recentOpen"
    case bin = "bin" // Delete aflter release 13
}
