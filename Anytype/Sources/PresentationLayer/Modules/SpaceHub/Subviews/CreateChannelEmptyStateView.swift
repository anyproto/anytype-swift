import SwiftUI

struct CreateChannelEmptyStateView: View {

    let onTapPersonal: () -> Void
    let onTapGroup: () -> Void
    let onTapJoinQR: () -> Void

    var body: some View {
        EmptyStateView(
            title: Loc.Channel.Create.EmptyState.title,
            subtitle: "",
            style: .withImage
        ) {
            Menu {
                CreateChannelMenuItems(
                    onTapPersonal: onTapPersonal,
                    onTapGroup: onTapGroup,
                    onTapJoinQR: onTapJoinQR
                )
            } label: {
                StandardButton(.text(Loc.Channel.Create.EmptyState.button), style: .secondarySmall) {}
                    .allowsHitTesting(false)
            }
        }
    }
}
