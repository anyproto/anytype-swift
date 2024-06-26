import Foundation
import SwiftUI

struct WidgetContainerWithEmptyState<Content: View>: View {
    
    let showEmpty: Bool
    let content: Content
    let onCreeateTap: (() -> Void)?
    
    init(showEmpty: Bool, onCreeateTap: (() -> Void)?, @ViewBuilder content: () -> Content) {
        self.showEmpty = showEmpty
        self.onCreeateTap = onCreeateTap
        self.content = content()
    }
    
    var body: some View {
        if showEmpty {
            VStack(spacing: 0) {
                WidgetEmptyView(onCreeateTap: onCreeateTap)
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
