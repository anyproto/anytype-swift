import SwiftUI

struct SpaceHubEmptyStateView: View {

    let onTapCreatePersonalChannel: () -> Void
    let onTapCreateGroupChannel: () -> Void
    let onTapJoinViaQrCode: () -> Void

    var body: some View {
        HomeUpdateSubmoduleView().padding(8)
        CreateChannelEmptyStateView(
            onTapPersonal: { onTapCreatePersonalChannel() },
            onTapGroup: { onTapCreateGroupChannel() },
            onTapJoinQR: { onTapJoinViaQrCode() }
        )
    }
}
