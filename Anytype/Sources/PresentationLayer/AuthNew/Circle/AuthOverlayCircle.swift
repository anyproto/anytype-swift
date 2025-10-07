import SwiftUI

extension View {
    func authOverlayCircle(show: Bool) -> some View {
        modifier(AuthOverlayCircleModifier(showCircle: show))
    }
}

struct AuthOverlayCircleModifier: ViewModifier {
    
    let showCircle: Bool
    @State private var curcleYOffset: CGFloat = 0
    @State private var safeArea = EdgeInsets()
    
    func body(content: Content) -> some View {
        content
            .alignmentGuide(.authCircle) { _ in
                MainActor.assumeIsolated {
                    curcleYOffset - safeArea.top
                }
            }
            .overlay(alignment: Alignment(horizontal: .center, vertical: .authCircle)) {
                if showCircle {
                    AuthCircle()
                        .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 15).combined(with: .opacity)))
                }
            }
            .readSafeArea {
                safeArea = $0
            }
            .environment(\.authCircleCenterVerticalOffset, $curcleYOffset)
    }
}
