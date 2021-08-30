import SwiftUI

struct RoundedButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(Color.background).cornerRadius(10)
    }
}

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
