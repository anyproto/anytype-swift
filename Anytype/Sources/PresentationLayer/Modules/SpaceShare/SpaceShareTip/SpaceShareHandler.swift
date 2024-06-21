import Foundation
import SwiftUI

extension View {
    func handleSpaceShareTip() -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(TipCustomViewPresentationModifiert(tip: SpaceShareTip(), view: { SpaceShareTipView() }))
        } else {
            return self
        }
    }
}
