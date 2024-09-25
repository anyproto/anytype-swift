import Foundation
import SwiftUI

extension View {
    func handleSpaceHubTip() -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(TipCustomViewPresentationModifiert(tip: SpaceHubTip(), view: { SpaceHubTipView() }))
        } else {
            return self
        }
    }
}
