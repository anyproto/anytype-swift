import SwiftUI
import AnytypeCore

struct SpaceHubNavBar: View {
    
    let profileIcon: Icon?
    let notificationsDenied: Bool
    let showLoading: Bool
    
    let onTapSettings: () -> Void
    let onTapCreateSpace: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                onTapSettings()
            } label: {
                IconView(icon: profileIcon)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 28, height: 28)
                    .overlay(alignment: .topTrailing) {
                        if notificationsDenied {
                            attentionDotView
                        }
                    }
                    .padding(.vertical, 8)
            }
            
            Spacer()
            
            title
            
            Spacer()
            
            Button { onTapCreateSpace() }
            label: {
                Image(asset: .X32.addFilled)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 32, height: 32)
                    .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 44)
    }
    
    private var title: some View {
        HStack(spacing: 6) {
            if showLoading {
                CircleLoadingView(.Text.primary)
                    .frame(width: 18, height: 18)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Spacer.fixedWidth(18)
            }
            
            AnytypeText(FeatureFlags.spaceHubNewTitle ? Loc.myChannels : Loc.mySpaces, style: .uxTitle1Semibold)
            
            Spacer.fixedWidth(18)
        }
    }
    
    private var attentionDotView: some View {
        Circle()
            .fill(Color.Pure.red)
            .frame(width: 6, height: 6)
            .padding([.top, .trailing], -4)
    }
}
