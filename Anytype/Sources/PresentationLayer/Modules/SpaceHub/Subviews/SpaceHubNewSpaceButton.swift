import SwiftUI

struct SpaceHubNewSpaceButton: View {
    
    @StateObject var spaceCreationTip = SpaceCreationTipWrapper()
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            spaceCreationTip.invalidate()
            onTap()
        }
        label: {
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
