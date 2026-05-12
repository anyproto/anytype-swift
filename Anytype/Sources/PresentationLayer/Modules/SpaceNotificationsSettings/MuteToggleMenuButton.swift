import SwiftUI

struct MuteToggleMenuButton: View {
    let isMuted: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            Label {
                Text(isMuted ? Loc.unmute : Loc.mute)
            } icon: {
                Image(systemName: isMuted ? "bell" : "bell.slash")
            }
        }
    }
}
