import Foundation
import UIKit

final class TopAlertView: UIView {
    
    private let label = UILabel()
    
    convenience init(title: String) {
        self.init(frame: .zero)
        label.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        backgroundColor = .backgroundSecondary
        label.textAlignment = .center
        label.font = .caption1Medium
        addSubview(label) {
            $0.height.equal(to: 18)
            $0.pinToSuperview(excluding: [], insets: UIEdgeInsets(top: 12, left: 32, bottom: -12, right: -32))
        }
        layer.cornerRadius = 21
    }
}
