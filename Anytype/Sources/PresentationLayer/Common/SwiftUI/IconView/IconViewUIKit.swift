import Foundation
import UIKit
import SwiftUI

final class IconViewUIKit: UIView {
    
    var icon: ObjectIconImage? {
        didSet {
            if oldValue != icon {
                updateIcon()
            }
        }
    }
    
    private func updateIcon() {
        removeAllSubviews()
        if let icon {
            let iconView = IconView(icon: icon).ignoresSafeArea()
            let hosting = UIHostingController(rootView: iconView)
            hosting.view.backgroundColor = .clear
            addSubview(hosting.view) {
                $0.pinToSuperview()
            }
        }
    }
}
