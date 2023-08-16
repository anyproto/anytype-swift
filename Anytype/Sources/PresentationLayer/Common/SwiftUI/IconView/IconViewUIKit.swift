import Foundation
import UIKit
import SwiftUI

final class IconViewUIKit: UIView {
    
    var icon: Icon? {
        didSet {
            if oldValue != icon {
                updateIcon()
            }
        }
    }
    
    init(icon: Icon? = nil) {
        self.icon = icon
        super.init(frame: .zero)
        updateIcon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateIcon() {
        removeAllSubviews()
        let iconView = IconView(icon: icon).ignoresSafeArea()
        let hosting = UIHostingController(rootView: iconView)
        hosting.view.backgroundColor = .clear
        addSubview(hosting.view) {
            $0.pinToSuperview()
        }
    }
}
