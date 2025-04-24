import SwiftUI
import AnytypeCore
import Assets

public struct AnytypeText: View {
    
    private let textView: Text
    private let spacing: CGFloat

    private init(textView: Text, spacing: CGFloat) {
        self.textView = textView
        self.spacing = spacing
    }

    public init(_ text: String?, style: AnytypeFont, enableMarkdown: Bool = false) {
        let spacing = style.lineSpacing
        
        self.textView = Self.buildText(text ?? "", style: style, enableMarkdown: enableMarkdown)
        self.spacing = spacing
    }
    
    public init(
        _ text: String?,
        font: FontConvertible,
        size: CGFloat,
        enableMarkdown: Bool = false
    ) {
        anytypeAssert(
            FontFamily.IBMPlexMono.all.contains(font),
            "Custom plex font requires custom line spacing implementation"
        )
        let font = AnytypeFontBuilder.font(font: font, size: size)
        let text = text ?? ""
        textView = (enableMarkdown ? Text(markdown: text) : Text(verbatim: text)).font(font)
        self.spacing = 0
    }
    
    public var body: some View {
        textView
            .foregroundStyle(Color.Text.primary)
            .modifier(OptionalLineSpacingModifier(spacing: spacing))
            // TODO: Fix
            // For two AnytypeText in VStack in List, multiline working incorrectly when padding is small (example: 1.8).
            // See featureToggle list in debug menu. Replace Text to AnytypeText.
            .padding(.vertical, spacing / 2)
    }
    
    // MARK: - SwiftUI Text mimic methods
    
    public func underline(_ isActive: Bool = true, color: Color? = nil) -> AnytypeText {
        let textView = textView.underline(isActive, color: color)
        return AnytypeText(textView: textView, spacing: spacing)
    }
    
    
    public func foregroundColor(_ color: Color) -> AnytypeText {
        let textView = textView.foregroundColor(color)
        return AnytypeText(textView: textView, spacing: spacing)
    }
    
    // MARK: - Private
    
    private static func buildText(_ text: String, style: AnytypeFont, enableMarkdown: Bool) -> Text {
        let font = AnytypeFontBuilder.font(anytypeFont: style)
        
        return (enableMarkdown ? Text(markdown: text) : Text(verbatim: text)).font(font).kerning(style.config.kern)
    }
    
    public static func + (lhs: AnytypeText, rhs: AnytypeText) -> AnytypeText {
        let textView = lhs.textView + rhs.textView
        let spacing = max(lhs.spacing, rhs.spacing)
        return AnytypeText(textView: textView, spacing: spacing)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnytypeText("Foo", style: .title)
            AnytypeText("Foo", style: .bodyRegular)
            AnytypeText("Foo", style: .relation3Regular)
            AnytypeText("collapse", style: .codeBlock)
        }
    }
}
