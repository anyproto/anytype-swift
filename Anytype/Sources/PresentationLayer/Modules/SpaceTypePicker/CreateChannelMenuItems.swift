import SwiftUI

struct CreateChannelMenuItems: View {

    let onTapPersonal: () -> Void
    let onTapGroup: () -> Void
    let onTapJoinQR: () -> Void

    var body: some View {
        Group {
            Button { onTapJoinQR() } label: {
                Label(Loc.Qr.Join.title, systemImage: "qrcode")
            }
            Button { onTapGroup() } label: {
                Label(Loc.Channel.Create.group, systemImage: "person.2.fill")
            }
            Button { onTapPersonal() } label: {
                Label(Loc.Channel.Create.personal, systemImage: "person.fill")
            }
        }
        .tint(Color.Control.primary)
    }
}
