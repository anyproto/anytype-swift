import SwiftUI

struct SpaceHubToolbar: ToolbarContent {
    
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onTapSettings()
            } label: {
                IconView(icon: profileIcon)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 44, height: 44)
                    .overlay(alignment: .topTrailing) {
                        if notificationsDenied {
                            attentionDotView
                        }
                    }
                    .padding(.vertical, 8)
            }
        }
        .sharedBackgroundVisibility(.hidden)
        
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
