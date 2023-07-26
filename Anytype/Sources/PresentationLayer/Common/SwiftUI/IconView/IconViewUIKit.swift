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
    
    init(icon: ObjectIconImage? = nil) {
        self.icon = icon
        super.init(frame: .zero)
        updateIcon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
