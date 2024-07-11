import Foundation
import SwiftUI

struct DiscussionSpacingContainer<Content: View>: View {
    
    let content: Content
    @Environment(\.anytypeNavigationPanelSize) var navigationSize
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { reader in
            GeometryReader { readerIgnoreKeyboard in
                content
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        Color.clear.frame(
                            height: reader.safeAreaInsets.bottom == readerIgnoreKeyboard.safeAreaInsets.bottom
                            ? reader.safeAreaInsets.bottom + navigationSize.height
                            : reader.safeAreaInsets.bottom
                        )
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
