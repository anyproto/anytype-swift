import SwiftUI

extension AnyTransition {
    static var sectionBody: AnyTransition {
        .modifier(
            active: SectionBodyModifier(yOffset: -12, opacity: 0),
            identity: SectionBodyModifier(yOffset: 0, opacity: 1)
        )
    }
}

private struct SectionBodyModifier: ViewModifier {
    let yOffset: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .offset(y: yOffset)
            .opacity(opacity)
    }
}
