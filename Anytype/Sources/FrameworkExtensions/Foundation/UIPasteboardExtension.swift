import UIKit

extension UIPasteboard {
    var hasSlots: Bool {
        UIPasteboard.general.items.count > 0
    }
}
