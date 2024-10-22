import Foundation
import SwiftUI

struct ChatSpacingContainer<Content: View>: View {
    
    let content: Content
    @Environment(\.anytypeNavigationPanelSize) var navigationSize
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { readerWithAllArea in
            GeometryReader { readerWithoutKeyboardArea in
                content
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        Color.clear.frame(
                            height: bottomOffset(
                                allAreaInsets: readerWithAllArea.safeAreaInsets,
                                withoutKeyboardAreaInsets: readerWithoutKeyboardArea.safeAreaInsets
                            )
                        )
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    private func bottomOffset(allAreaInsets: EdgeInsets, withoutKeyboardAreaInsets: EdgeInsets) -> CGFloat {
        return allAreaInsets.bottom == withoutKeyboardAreaInsets.bottom
            ? allAreaInsets.bottom + navigationSize.height
            : allAreaInsets.bottom
    }
}
