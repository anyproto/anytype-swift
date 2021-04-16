
import UIKit

final class BlockActionsView: UIView {
    
    private enum Constants {
        static let separatorHeight: CGFloat = 0.5
    }
    
    private weak var parentTextView: UITextView?
    private let positionOfFirstSymbolToGetFilterString: Int
    
    init(parentTextView: UITextView, frame: CGRect) {
        self.parentTextView = parentTextView
        let selectedRange = parentTextView.selectedRange
        self.positionOfFirstSymbolToGetFilterString = selectedRange.location + selectedRange.length
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        topSeparator.backgroundColor = .systemGray4
        self.addSubview(topSeparator)
        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: self.topAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            topSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
