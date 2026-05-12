import SwiftUI
import AnytypeCore

struct SpaceHubNewSpaceButton: View {
    
    @StateObject var spaceCreationTip = SpaceCreationTipWrapper()
    
    let onTap: () -> Void
    let onTapPersonal: () -> Void
    let onTapGroup: () -> Void
    let onTapJoinQR: () -> Void
    
    var body: some View {
        if FeatureFlags.createChannelFlow {
            menuContent
        } else {
            buttonContent
        }
    }
    
    private var buttonContent: some View {
        Button {
            spaceCreationTip.invalidate()
            onTap()
        }
        label: {
            buttonLabel
        }
        .accessibilityLabel("NewSpaceButton")
    }
    
    private var menuContent: some View {
        Menu {
            CreateChannelMenuItems(
                onTapPersonal: { spaceCreationTip.invalidate(); onTapPersonal() },
                onTapGroup: { spaceCreationTip.invalidate(); onTapGroup() },
                onTapJoinQR: { spaceCreationTip.invalidate(); onTapJoinQR() }
            )
        } label: {
            buttonLabel
        }
        .accessibilityLabel("NewSpaceButton")
    }
    
    private var buttonLabel: some View {
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
}
