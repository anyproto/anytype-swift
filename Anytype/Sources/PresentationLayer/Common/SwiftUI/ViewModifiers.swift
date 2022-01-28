import SwiftUI

struct RoundedButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(Color.backgroundPrimary).cornerRadius(10)
    }
}

struct DividerModifier: ViewModifier {
    
    let spacing: CGFloat?
    let leadingPadding: CGFloat
    let trailingPadding: CGFloat
    let alignment: HorizontalAlignment
    
    init(spacing: CGFloat? = nil, leadingPadding: CGFloat = 0, trailingPadding: CGFloat = 0, alignment: HorizontalAlignment? = nil) {
        self.spacing = spacing
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        self.alignment = alignment ?? .center
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
            Divider()
                .foregroundColor(Color.strokePrimary)
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
        }
    }
}
