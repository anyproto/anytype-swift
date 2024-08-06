import Foundation
import SwiftUI

struct WidgetContainerWithEmptyState<Content: View>: View {
    
    let showEmpty: Bool
    let content: Content
    let onCreateTap: (() -> Void)?
    
    init(showEmpty: Bool, onCreateTap: (() -> Void)?, @ViewBuilder content: () -> Content) {
        self.showEmpty = showEmpty
        self.onCreateTap = onCreateTap
        self.content = content()
    }
    
    var body: some View {
        if showEmpty {
            VStack(spacing: 0) {
                WidgetEmptyView(onCreateTap: onCreateTap)
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
