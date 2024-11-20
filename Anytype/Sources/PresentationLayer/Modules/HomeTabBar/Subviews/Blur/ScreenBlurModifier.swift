import SwiftUI

extension View {
    func screenBlue(topHeight: CGFloat = 0, bottomHeight: CGFloat = 0, handleBottomNavigatioinSpacer: Bool = false) -> some View {
        modifier(ScreenBlurModifier(topHeight: topHeight, bottomHeight: bottomHeight, handleBottomNavigatioinSpacer: handleBottomNavigatioinSpacer))
    }
}

private struct ScreenBlurModifier: ViewModifier {
    
    let topHeight: CGFloat
    let bottomHeight: CGFloat
    let handleBottomNavigatioinSpacer: Bool
    
    init(topHeight: CGFloat, bottomHeight: CGFloat, handleBottomNavigatioinSpacer: Bool) {
        self.topHeight = max(topHeight, 1)
        self.handleBottomNavigatioinSpacer = handleBottomNavigatioinSpacer
        self.bottomHeight = max(bottomHeight, 1)
    }
    
    @State private var safeArea = EdgeInsets()
    
    @Environment(\.anytypeNavigationPanelSize) var navigationSize
    
    func body(content: Content) -> some View {
        content
            .readSafeArea { insets in
                safeArea = insets
            }
            .overlay(alignment: .top) {
                HomeBlurEffectView(direction: .topToBottom)
                    .ignoresSafeArea()
                    .frame(height: topHeight)
            }
            .overlay(alignment: .bottom) {
                HomeBlurEffectView(direction: .bottomToTop)
                    .ignoresSafeArea()
                    .frame(height: bottomFullHeight)
            }
    }
    
    private var bottomFullHeight: CGFloat {
        handleBottomNavigatioinSpacer ? max(navigationSize.height, bottomHeight) : bottomHeight
    }
}
