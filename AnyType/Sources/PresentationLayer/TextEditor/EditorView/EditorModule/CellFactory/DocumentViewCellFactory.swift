import UIKit

final class DocumentViewCellFactory: DocumentViewCellFactoryProtocol {
    
    private let selectedViewColor: UIColor = .selectedItemColor
    private let selectedViewCornerRadius: CGFloat = 8
    
    func makeSelectedBackgroundViewForBlockCell() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = self.selectedViewCornerRadius
        view.backgroundColor = self.selectedViewColor
        return view
    }
}
