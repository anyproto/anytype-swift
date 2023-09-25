import Foundation
import SwiftUI
import NavigationBackport

struct HomeBottomPanelContainer<Content: View, BottomContent: View>: View {
    
    @State private var bottomPanelHidden = false
    
    private var content: Content
    private var bottomPanel: BottomContent
    @Binding private var path: NBNavigationPath
    
    init(path: Binding<NBNavigationPath>, @ViewBuilder content: () -> Content, @ViewBuilder bottomPanel: () -> BottomContent) {
        self._path = path
        self.content = content()
        self.bottomPanel = bottomPanel()
    }
    
    var body: some View {
        content
        .onChange(of: path.count) { newValue in
            print("on change count - false")
            bottomPanelHidden = false
        }
        .safeAreaInset(edge: .bottom) {
            if !bottomPanelHidden {
                VStack(spacing: 0) {
                    bottomPanel
                        .transition(.move(edge: .bottom))
                    Spacer.fixedHeight(32)
                }
            }
        }
        .setHomeBottomPanelHiddenHandler { newValue in
            print("setBottomPanelHidden - \(newValue)")
            bottomPanelHidden = newValue
        }
        .ignoresSafeArea(bottomPanelHidden ? .keyboard : .all) // TODO: Check in subviews
    }
}
