import SwiftUI
import UIKit
import AnytypeCore

extension AnytypeColor {
    var asUIColor: UIColor {
        guard let color = UIColor(named: self.rawValue) else {
            anytypeAssertionFailure("No color named: \(self.rawValue)", domain: .anytypeColor)
            return .grayscale90
        }
        return color
    }
    var asColor: Color {
        Color(self.rawValue)
    }
}
