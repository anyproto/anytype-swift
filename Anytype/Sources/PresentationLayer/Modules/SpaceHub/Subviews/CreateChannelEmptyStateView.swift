import SwiftUI

struct CreateChannelEmptyStateView: View {

    let onTapPersonal: () -> Void
    let onTapGroup: () -> Void
    let onTapJoinQR: () -> Void

    var body: some View {
        EmptyStateView(
            title: Loc.thereAreNoSpacesYet,
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
                StandardButton(.text(Loc.createSpace), style: .secondarySmall) {}
                    .allowsHitTesting(false)
            }
        }
    }
}
