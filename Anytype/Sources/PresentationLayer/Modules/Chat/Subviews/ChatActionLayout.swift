import SwiftUI

struct ChatActionOverlayState {
    fileprivate var offset: CGFloat = 0
}

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
    
    @Binding var state: ChatActionOverlayState
    @ViewBuilder let overlayView: OverlayContent
    
    @State private var currentOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            // Custom coordinator space doens't work in bottom panel inside UIHostingController
            .readFrame {
                currentOffset = $0.minY
            }
            .alignmentGuide(.chatAction) { guide in
                // Fix concurrency error
                let top = guide[.top]
                return MainActor.assumeIsolated {
                    return top + offset
                }
            }
            .overlay(alignment: .chatAction) {
                overlayView
            }
    }
    
    private var offset: CGFloat {
        state.offset - currentOffset
    }
}

private struct ChatActionStateTopProvider: ViewModifier {
    
    @Binding var state: ChatActionOverlayState
    
    func body(content: Content) -> some View {
        content
            .readFrame {
                state.offset = $0.minY
            }
    }
}

extension View {
    func chatActionOverlay<OverlayContent: View>(state: Binding<ChatActionOverlayState>, @ViewBuilder overlayView: () -> OverlayContent) -> some View {
        modifier(ChatActionViewModifier(state: state, overlayView: overlayView))
    }
    
    func chatActionStateTopProvider(state: Binding<ChatActionOverlayState>) -> some View {
        modifier(ChatActionStateTopProvider(state: state))
    }
}
