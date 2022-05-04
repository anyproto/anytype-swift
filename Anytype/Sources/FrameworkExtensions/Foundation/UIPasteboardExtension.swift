import UIKit

extension UIPasteboard {
    var hasSlots: Bool {
        UIPasteboard.general.numberOfItems > 0
    }
}
