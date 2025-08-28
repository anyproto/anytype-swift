import Foundation
import SwiftUI

struct WidgetContainerWithEmptyState<Content: View>: View {
    
    let showEmpty: Bool
    let content: Content
    
    init(showEmpty: Bool, @ViewBuilder content: () -> Content) {
        self.showEmpty = showEmpty
        self.content = content()
    }
    
    var body: some View {
        if showEmpty {
            VStack(spacing: 0) {
                WidgetEmptyView()
                    .frame(height: showEmpty ? 72 : 0)
                Spacer.fixedHeight(8)
            }
            .transition(.opacity)
        } else {
            content
                .transition(.opacity)
        }
    }
}
