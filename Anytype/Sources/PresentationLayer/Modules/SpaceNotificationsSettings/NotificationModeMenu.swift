import SwiftUI
import Services

struct NotificationModeMenu: View {
    let currentMode: SpacePushNotificationsMode
    let onModeChange: (SpacePushNotificationsMode) async -> Void

    var body: some View {
        Menu {
            ForEach([SpacePushNotificationsMode.all, .mentions, .nothing], id: \.self) { mode in
                Button {
                    Task {
                        await onModeChange(mode)
                    }
                } label: {
                    HStack {
                        Text(mode == .nothing ? Loc.Space.Notifications.Settings.State.muteAndHide : mode.title)
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
                Image(systemName: "bell.fill")
            }
        }
    }
}
