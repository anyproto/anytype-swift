import SwiftUI
import AnytypeCore

struct SpaceHubEmptyStateView: View {
    
    let onTapCreateSpace: () -> Void
    let onTapCreatePersonalChannel: () -> Void
    let onTapCreateGroupChannel: () -> Void
    let onTapJoinViaQrCode: () -> Void
    
    var body: some View {
        HomeUpdateSubmoduleView().padding(8)
        if FeatureFlags.createChannelFlow {
            channelMenuEmptyState
        } else {
            EmptyStateView(
                title: Loc.thereAreNoSpacesYet,
                subtitle: "",
                style: .withImage,
                buttonData: EmptyStateView.ButtonData(title: Loc.createSpace) {
                    onTapCreateSpace()
                }
            )
        }
    }
    
    private var channelMenuEmptyState: some View {
        CreateChannelEmptyStateView(
            onTapPersonal: { onTapCreatePersonalChannel() },
            onTapGroup: { onTapCreateGroupChannel() },
            onTapJoinQR: { onTapJoinViaQrCode() }
        )
    }
}
