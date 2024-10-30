import Foundation
import SwiftUI

struct HomeTabBarView: View {

    let icon: Icon?
    @Binding var state: HomeTabState
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    
    var body: some View {
        HStack(spacing: 0) {
            
            makeButton(asset: .X32.widgets, buttonState: .widgets)
            
            Spacer()
            
            IconView(icon: icon)
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.25), radius: 20, y: 4)
            
            Spacer()
            
            makeButton(asset: .X32.chat, buttonState: .chat)
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
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
