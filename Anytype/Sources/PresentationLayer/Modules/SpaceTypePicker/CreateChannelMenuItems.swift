import SwiftUI

struct CreateChannelMenuItems: View {

    let onTapPersonal: () -> Void
    let onTapGroup: () -> Void
    let onTapJoinQR: () -> Void

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                // iOS 26 reverses menu items for bottom bar placement
                qrButton
                groupButton
                personalButton
            } else {
                // iOS 18 does not reverse — specify desired visual order directly
                personalButton
                groupButton
                qrButton
            }
        }
        .tint(Color.Control.primary)
    }

    private var personalButton: some View {
        Button { onTapPersonal() } label: {
            Label(Loc.Channel.Create.personal, systemImage: "person.fill")
        }
    }

    private var groupButton: some View {
        Button { onTapGroup() } label: {
            Label(Loc.Channel.Create.group, systemImage: "person.2.fill")
        }
    }

    private var qrButton: some View {
        Button { onTapJoinQR() } label: {
            Label(Loc.Qr.Join.title, systemImage: "qrcode")
        }
    }
}
