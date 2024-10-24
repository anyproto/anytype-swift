import Foundation
import SwiftUI

struct HomeBottomPanelContainer<Content: View, BottomContent: View>: View {
    
    @State private var bottomPanelState = HomeBottomPanelState()
    
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
        ZStack(alignment: .bottom) {
            content
                .anytypeNavigationPanelSize(bottomSize)
            
            bottomPanel
                .readSize {
                    bottomSize = $0
                }
                .anytypeIgnoreBottomSafeArea()
                .opacity(bottomPanelHidden ? 0 : 1)
                .animation(.default, value: path.count)
        }
        .homeBottomPanelState($bottomPanelState)
    }
    
    private var bottomPanelHidden: Bool {
        for item in path.path.reversed() {
            if let state = bottomPanelState.hidden(for: item) {
                return state
            }
        }
        return false
    }
}
