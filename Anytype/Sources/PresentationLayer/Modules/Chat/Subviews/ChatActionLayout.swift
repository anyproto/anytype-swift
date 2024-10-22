import SwiftUI

private struct ChatActionAlignmentGuide: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.bottom]
    }
}

private extension VerticalAlignment {
    static let chatAction = VerticalAlignment(ChatActionAlignmentGuide.self)
}

private extension Alignment {
    static let chatAction = Alignment(horizontal: .center, vertical: .chatAction)
}

private struct ChatActionViewModifier<OverlayContent: View>: ViewModifier {
    
    @Binding var offset: CGFloat
    @ViewBuilder let overlayView: OverlayContent
    
    func body(content: Content) -> some View {
        content
            .alignmentGuide(.chatAction) { $0[.top] + offset }
            .overlay(alignment: .chatAction) {
                overlayView
            }
            .coordinateSpace(name: "ChatActionViewModifier")
    }
}

private struct ChatActionStateTopProvider: ViewModifier {
    
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .readFrame(space: .named("ChatActionViewModifier")) {
                offset = $0.minY
            }
    }
}

extension View {
    func chatActionOverlay<OverlayContent: View>(state: Binding<CGFloat>, @ViewBuilder overlayView: () -> OverlayContent) -> some View {
        modifier(ChatActionViewModifier(offset: state, overlayView: overlayView))
    }
    
    func chatActionStateTopProvider(state: Binding<CGFloat>) -> some View {
        modifier(ChatActionStateTopProvider(offset: state))
    }
}
