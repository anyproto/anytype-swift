import SwiftUI

struct DividerModifier: ViewModifier {
    
    let spacing: CGFloat?
    
    init(spacing: CGFloat? = nil) {
        self.spacing = spacing
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: spacing) {
            content
            Divider().foregroundColor(Color.divider)
        }
    }
}
