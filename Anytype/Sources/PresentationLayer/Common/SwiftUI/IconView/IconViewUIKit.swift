import Foundation
import UIKit
import SwiftUI

final class IconViewUIKit: UIView {
    
    private let hosting: UIHostingController<AnyView>
    
    var icon: Icon? {
        didSet {
            if oldValue != icon {
                updateIcon()
            }
        }
    }
    
    init(icon: Icon? = nil) {
        self.icon = icon
        self.hosting = UIHostingController(rootView: EmptyView().eraseToAnyView())
        super.init(frame: .zero)
        
        hosting.view.backgroundColor = .clear
        addSubview(hosting.view) {
            $0.pinToSuperview()
        }
        updateIcon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateIcon() {
        hosting.rootView = IconView(icon: icon).ignoresSafeArea().eraseToAnyView()
    }
}
