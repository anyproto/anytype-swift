import SwiftUI

extension View {
    func divider(
        spacing: CGFloat = 0,
        leadingPadding: CGFloat = 0,
        trailingPadding: CGFloat = 0,
        alignment: HorizontalAlignment = .center
    ) -> some View {
        modifier(
            DividerModifier(
                spacing: spacing, leadingPadding: leadingPadding, trailingPadding: trailingPadding, alignment: alignment
            )
        )
    }
    
    func newDivider(
        leadingPadding: CGFloat = 0,
        trailingPadding: CGFloat = 0
    ) -> some View {
        modifier(
            NewDividerModifier(leadingPadding: leadingPadding, trailingPadding: trailingPadding)
        )
    }
}

struct AnytypeDivider: View {
    var body: some View {
        Color.Stroke.primary.frame(height: .onePixel)
    }
}

final class UIKitAnytypeDivider: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .Stroke.primary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: .greatestFiniteMagnitude, height: .onePixel)
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: .greatestFiniteMagnitude, height: .onePixel)
    }
}

struct DividerModifier: ViewModifier {
    let spacing: CGFloat?
    let leadingPadding: CGFloat
    let trailingPadding: CGFloat
    let alignment: HorizontalAlignment
    
    init(spacing: CGFloat, leadingPadding: CGFloat, trailingPadding: CGFloat, alignment: HorizontalAlignment) {
        self.spacing = spacing
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        self.alignment = alignment
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

struct NewDividerModifier: ViewModifier {
    let leadingPadding: CGFloat
    let trailingPadding: CGFloat
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .overlay(alignment: .bottom) {
                    AnytypeDivider()
                        .padding(.leading, leadingPadding)
                        .padding(.trailing, trailingPadding)
                }
        } else {
            content
        }
    }
}
