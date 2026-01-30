import Foundation
import Services

enum ChatIconSelection {
    case file(FileData)
    case emoji(EmojiData)
}

enum ChatIconState {
    case unchanged(originalIcon: Icon?)  // nil for create mode, Icon for edit mode
    case selected(ChatIconSelection)
    case removed
}

struct ChatIconPickerData: Identifiable {
    let id = UUID()
    let iconSelection: ChatIconSelection?
    let originalObjectIcon: ObjectIcon?  // nil if create mode or already removed

    var hasRemovableIcon: Bool {
        if iconSelection != nil {
            return true
        }
        return originalObjectIcon?.isChatIconRemovable ?? false
    }
}

// MARK: - ObjectIcon Chat Removability

extension ObjectIcon {
    /// Whether this icon type can be removed in the chat icon picker context.
    /// This is specific to the chat create/edit flow.
    var isChatIconRemovable: Bool {
        switch self {
        case .emoji, .basic, .profile, .space:
            return true
        case .customIcon, .bookmark, .todo, .placeholder, .file, .deleted:
            return false
        }
    }
}
