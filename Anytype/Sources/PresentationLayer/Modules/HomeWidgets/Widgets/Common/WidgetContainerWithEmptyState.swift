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
        ZStack {
            VStack(spacing: 0) {
                WidgetEmptyView(title: Loc.Widgets.Empty.title)
                    .frame(height: showEmpty ? 72 : 0)
                Spacer.fixedHeight(8)
            }
            .setZeroOpacity(!showEmpty)
            .transition(.opacity)
            
            content
                .setZeroOpacity(showEmpty)
        }
    }
}
