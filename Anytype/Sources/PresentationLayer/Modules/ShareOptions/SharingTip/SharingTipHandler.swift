import UIKit
import SwiftUI

extension View {
    func handleSharingTip() -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(TipCustomViewPresentationModifier(tip: SharingTip(), view: { SharingTipView() }))
        } else {
            return self
        }
    }
}
