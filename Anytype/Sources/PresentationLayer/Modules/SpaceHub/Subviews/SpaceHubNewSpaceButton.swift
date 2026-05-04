import SwiftUI

struct SpaceHubNewSpaceButton: View {

    @StateObject var spaceCreationTip = SpaceCreationTipWrapper()

    let onTapPersonal: () -> Void
    let onTapGroup: () -> Void
    let onTapJoinQR: () -> Void

    var body: some View {
        Menu {
            CreateChannelMenuItems(
                onTapPersonal: { spaceCreationTip.invalidate(); onTapPersonal() },
                onTapGroup: { spaceCreationTip.invalidate(); onTapGroup() },
                onTapJoinQR: { spaceCreationTip.invalidate(); onTapJoinQR() }
            )
        } label: {
            Image(asset: .X32.addFilled)
                .foregroundStyle(Color.Control.secondary)
                .frame(width: 32, height: 32)
                .overlay(alignment: .bottomLeading) {
                    if spaceCreationTip.shouldDisplay {
                        AttentionDotView()
                    }
                }
                .padding(.vertical, 6)
        }
        .accessibilityLabel("NewSpaceButton")
    }
}
