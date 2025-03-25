import Foundation

public enum AnytypeWidgetId: String, CaseIterable, Sendable {
    case favorite = "favorite"
    case sets = "set"
    case collections = "collection"
    case recent = "recent"
    case recentOpen = "recentOpen"
    case bin = "bin"
    // All object types
    case pages = "pages"
    case lists = "lists"
    case media = "media"
    case bookmarks = "bookmark"
    case files = "files"
}
