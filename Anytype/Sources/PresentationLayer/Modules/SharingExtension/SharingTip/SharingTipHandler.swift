import UIKit
import SwiftUI

extension View {
    func handleSharingTip() -> some View {
        self.modifier(TipCustomViewPresentationModifier(tip: SharingTip(), view: { SharingTipView() }))
    }
}
