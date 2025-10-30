import SwiftUI


@MainActor
public extension Text {
    func anytypeStyle(_ style: AnytypeFont) -> some View {
        self
            .anytypeFontStyle(style)
            .anytypeLineHeightStyle(style)
    }
    
    func anytypeFontStyle(_ style: AnytypeFont) -> Text {
        self
            .font(AnytypeFontBuilder.font(anytypeFont: style))
            .kerning(style.config.kern)
    }
}

@MainActor
public extension TextField {
    func anytypeFontStyle(_ style: AnytypeFont) -> some View {
        self
            .font(AnytypeFontBuilder.font(anytypeFont: style))
            .kerning(style.config.kern)
            .anytypeLineHeightStyle(style)
    }
}

public extension View {
    func anytypeLineHeightStyle(_ style: AnytypeFont) -> some View {
        if #available(iOS 26, *) {
            return self.lineHeight(.exact(points: style.config.lineHeight))
        } else {
            return self.environment(\._lineHeightMultiple, style.lineHeightMultiple)
        }
    }
}

#Preview("Join 1 option") {
    TextPreview {
        Text("ABC \(Text("DEF").foregroundColor(.red).anytypeFontStyle(.bodyRegular))")
            .foregroundColor(.blue)
            .anytypeStyle(.bodySemibold)
    }
}

#Preview("Join 2 option") {
    TextPreview {
        Group {
            Text("ABC")
                .foregroundColor(.blue)
                .anytypeFontStyle(.bodySemibold)
            +
            Text("DEF")
                .foregroundColor(.red)
                .anytypeFontStyle(.bodyRegular)
        }
        .anytypeLineHeightStyle(.bodyRegular)
    }
}

// For check line height in preview
private struct TextPreview<Content: View>: View {
    
    let content: Content
    
    @State private var contentSize: CGSize = .zero
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
                .readSize {
                    contentSize = $0
                }
            Text("Size \(contentSize.debugDescription)")
        }
    }
}
