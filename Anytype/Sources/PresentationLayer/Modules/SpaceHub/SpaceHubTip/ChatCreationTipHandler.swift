import UIKit
import SwiftUI

extension View {
    func handleChatCreationTip() -> some View {
        self.modifier(TipCustomViewPresentationModifier(tip: ChatCreationTip(), view: { ChatCreationTipView() }))
    }
}
