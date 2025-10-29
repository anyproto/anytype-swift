import SwiftUI

struct SpaceHubToolbar: ToolbarContent {
    
    let showLoading: Bool
    let profileIcon: Icon?
    let notificationsDenied: Bool
    let namespace: Namespace.ID
    
    let onTapCreateSpace: () -> Void
    let onTapSettings: () -> Void
    
    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ios26ToolbarItems
        } else {
            legacyToolbarItems
        }
    }
    
    @ToolbarContentBuilder
    private var legacyToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 6) {
                if showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer.fixedWidth(18)
                }
                
                AnytypeText(Loc.myChannels, style: .uxTitle1Semibold)
                
                Spacer.fixedWidth(18)
            }
        }
        
        
        ToolbarItem(placement: .topBarLeading) {
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
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            SpaceHubNewSpaceButton {
                onTapCreateSpace()
            }
        }
    }
    
    @available(iOS 26.0, *)
    @ToolbarContentBuilder
    private var ios26ToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 6) {
                if showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer.fixedWidth(18)
                }
                
                AnytypeText(Loc.myChannels, style: .uxTitle1Semibold)
                
                Spacer.fixedWidth(18)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
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
        }
        
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
        
        ToolbarSpacer(placement: .bottomBar)

        ToolbarItem(placement: .bottomBar) {
            Button { onTapCreateSpace() } label: { Label("", systemImage: "plus") }
        }
        .matchedTransitionSource(id: "SpaceCreateTypePickerView", in: namespace)
    }
    
    private var attentionDotView: some View {
        SpaceHubAttentionDotView()
            .padding([.top, .trailing], 1)
    }
}
