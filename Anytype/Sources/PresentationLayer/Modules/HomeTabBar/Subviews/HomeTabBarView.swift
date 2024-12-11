import Foundation
import SwiftUI

struct HomeTabBarView: View {

    static let height: CGFloat = 64
    
    let name: String
    let icon: Icon?
    @Binding var state: HomeTabState
    let onIconTap: () -> Void
    
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    
    var body: some View {
        HStack(spacing: 0) {
            
            IconView(icon: icon)
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.25), radius: 20, y: 4)
                .onTapGesture {
                    onIconTap()
                }
            
            Spacer.fixedWidth(12)
            
            Text(name)
                .anytypeStyle(.previewTitle2Medium)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
            
            Spacer()
            
            Spacer.fixedWidth(16)
            makeButton(asset: .X32.widgets, buttonState: .widgets)
            Spacer.fixedWidth(16)
            makeButton(asset: .X32.chat, buttonState: .chat)
        }
        .padding(.horizontal, 20)
        .frame(height: HomeTabBarView.height)
    }
    
    private func makeButton(asset: ImageAsset, buttonState: HomeTabState) -> some View {
        Image(asset: asset)
            .foregroundStyle(
                state == buttonState ? Color.Control.button : Color.Control.navPanelIcon
            )
            .onTapGesture {
                withAnimation {
                    state = buttonState
                    keyboardDismiss()
                }
            }
    }
}
