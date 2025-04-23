import SwiftUI

public struct OptionalLineSpacingModifier: ViewModifier {
    var spacing: CGFloat?

    public func body(content: Content) -> some View {
        spacing.map { spacing in
            // TODO: Negative line spacing not working.
            content.lineSpacing(spacing).eraseToAnyView()
        } ?? content.eraseToAnyView()
    }
}
