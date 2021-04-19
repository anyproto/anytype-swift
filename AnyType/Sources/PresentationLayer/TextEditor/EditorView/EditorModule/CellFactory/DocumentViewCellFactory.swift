

import UIKit

/// Concrete factory for views for document
final class DocumentViewCellFactory: DocumentViewCellFactoryProtocol {
    
    private let selectedViewColor: UIColor
    private let selectedViewCornerRadius: CGFloat
    
    init(selectedViewColor: UIColor,
         selectedViewCornerRadius: CGFloat) {
        self.selectedViewColor = selectedViewColor
        self.selectedViewCornerRadius = selectedViewCornerRadius
    }
    
    func makeSelectedBackgroundViewForBlockCell() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = self.selectedViewCornerRadius
        view.backgroundColor = self.selectedViewColor
        return view
    }
}
