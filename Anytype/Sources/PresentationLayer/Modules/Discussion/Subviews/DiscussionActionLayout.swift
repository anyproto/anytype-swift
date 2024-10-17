import SwiftUI

private struct DiscussionActionAlignmentGuide: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.bottom]
    }
}

private extension VerticalAlignment {
    static let discussionAction = VerticalAlignment(DiscussionActionAlignmentGuide.self)
}

private extension Alignment {
    static let discussionAction = Alignment(horizontal: .center, vertical: .discussionAction)
}

private struct DiscussionActionViewModifier<OverlayContent: View>: ViewModifier {
    
    @Binding var offset: CGFloat
    @ViewBuilder let overlayView: OverlayContent
    
    func body(content: Content) -> some View {
        content
            .alignmentGuide(.discussionAction) { $0[.top] + offset }
            .overlay(alignment: .discussionAction) {
                overlayView
            }
            .coordinateSpace(name: "DiscussionActionViewModifier")
    }
}

private struct DiscussionActionStateTopProvider: ViewModifier {
    
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .readFrame(space: .named("DiscussionActionViewModifier")) {
                offset = $0.minY
            }
    }
}

extension View {
    func discussionActionOverlay<OverlayContent: View>(state: Binding<CGFloat>, @ViewBuilder overlayView: () -> OverlayContent) -> some View {
        modifier(DiscussionActionViewModifier(offset: state, overlayView: overlayView))
    }
    
    func discussionActionStateTopProvider(state: Binding<CGFloat>) -> some View {
        modifier(DiscussionActionStateTopProvider(offset: state))
    }
}
