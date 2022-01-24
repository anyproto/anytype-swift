import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class RelationDetailsViewPopupBehavior: FloatingPanelBehavior {
    let springDecelerationRate: CGFloat = UIScrollView.DecelerationRate.fast.rawValue
    let springResponseTime: CGFloat = 0.3
}
