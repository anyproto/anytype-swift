import SwiftUI

enum DiscussionNotificationMode: Hashable {
    case allNewReplies
    case mentionsOnly

    var title: String {
        switch self {
        case .allNewReplies:
            Loc.Discussion.Notifications.allNewReplies
        case .mentionsOnly:
            Loc.Discussion.Notifications.mentionsOnly
        }
    }
}

struct DiscussionNotificationsMenu: View {
    let currentMode: DiscussionNotificationMode
    let onModeChange: (DiscussionNotificationMode) async -> Void

    var body: some View {
        Menu {
            ForEach([DiscussionNotificationMode.allNewReplies, .mentionsOnly], id: \.self) { mode in
                Button {
                    Task {
                        await onModeChange(mode)
                    }
                } label: {
                    HStack {
                        Text(mode.title)
                        if currentMode == mode {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label {
                Text(Loc.notifications)
            } icon: {
                Image(systemName: "bell")
            }
        }
    }
}
