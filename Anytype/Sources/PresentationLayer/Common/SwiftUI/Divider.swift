import SwiftUI

struct AnytypeDivider: View {
    var body: some View {
        Color.strokePrimary.frame(height:CGFloat(1) / UIScreen.main.scale)
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
            AnytypeDivider()
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
        }
    }
}
