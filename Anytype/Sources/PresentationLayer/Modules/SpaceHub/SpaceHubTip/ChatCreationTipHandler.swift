import UIKit
import SwiftUI

extension View {
    func handleChatCreationTip() -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(TipCustomViewPresentationModifier(tip: ChatCreationTip(), view: { ChatCreationTipView() }))
        } else {
            return self
        }
    }
}
