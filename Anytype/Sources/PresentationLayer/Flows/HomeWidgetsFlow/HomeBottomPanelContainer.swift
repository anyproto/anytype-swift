import Foundation
import SwiftUI
import NavigationBackport

struct HomeBottomPanelContainer<Content: View>: View {
    
    @State private var bottomPanelHidden = false
    
    private var content: Content
    @Binding private var path: NBNavigationPath
    
    init(path: Binding<NBNavigationPath>, @ViewBuilder content: () -> Content) {
        self._path = path
        self.content = content()
    }
    
    var body: some View {
        content
        .onChange(of: path.count) { newValue in
            print("on change count - false")
            bottomPanelHidden = false
        }
        .safeAreaInset(edge: .bottom) {
            if !bottomPanelHidden {
                bottomPanel
                    .transition(.move(edge: .bottom))
            }
        }
        .setHomeBottomPanelHiddenHandler { newValue in
            print("setBottomPanelHidden - \(newValue)")
            bottomPanelHidden = newValue
        }
        .ignoresSafeArea(.keyboard) // TODO: Check in subviews
    }
    
    @ViewBuilder
    private var bottomPanel: some View {
        HStack(spacing: 49) {
            Image(asset: path.count > 0 ? .X32.Arrow.left : .X32.Arrow.right)
                .frame(width: 32, height: 32)
                .onTapGesture {
                    // Test action
                    path.popToRoot()
                }
        }
        .frame(height: 52)
        .padding(.horizontal, 23)
        .background(Color.white.opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(16, style: .continuous)
    }
}
