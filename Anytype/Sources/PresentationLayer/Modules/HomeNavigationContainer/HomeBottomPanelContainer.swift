import Foundation
import SwiftUI

struct HomeBottomPanelContainer<Content: View, BottomContent: View>: View {
    
    @State private var bottomPanelHidden = false
    
    private var content: Content
    private var bottomPanel: BottomContent
    @Binding private var path: HomePath
    @State private var bottomSize: CGSize = .zero
    
    init(path: Binding<HomePath>, @ViewBuilder content: () -> Content, @ViewBuilder bottomPanel: () -> BottomContent) {
        self._path = path
        self.content = content()
        self.bottomPanel = bottomPanel()
    }
    
    var body: some View {
        content
            .anytypeNavigationPanelSize(bottomSize)
            .onChange(of: path.count) { newValue in
                withAnimation {
                    bottomPanelHidden = false
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !bottomPanelHidden {
                    bottomPanel
                        .readSize {
                            bottomSize = $0
                        }
                        .transition(.opacity)
                }
            }
            .setHomeBottomPanelHiddenHandler($bottomPanelHidden)
            .ignoresSafeArea(.keyboard)
    }
}
