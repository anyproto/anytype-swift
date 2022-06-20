import Foundation
import UIKit
import Combine

final class TableOfContentsView: UIView, BlockContentView {
    
    // MARK: - Private properties
    
    private enum Constants {
        static let levelLeftOffset: CGFloat = 20
        static let verticalBoundsInset: CGFloat = 6
        static let verticalInnerInset: CGFloat = 12
        static let emptySize = CGSize(width: 20, height: 50)
    }
    
    private lazy var subscriptions = [AnyCancellable]()
    private var configuration: TableOfContentsConfiguration?
    private var contentProvider: TableOfContentsContentProvider?
    private var labels = [UILabel]()
    
    // MARK: - BlockContentView
    
    func update(with configuration: TableOfContentsConfiguration) {
        subscriptions.removeAll()
        
        contentProvider = configuration.contentProviderBuilder()
        
        contentProvider?.$content.sink { [weak self] content in
            self?.updateView(content: content)
        }.store(in: &subscriptions)
        
        self.configuration = configuration
    }
    
    private func updateView(content: [TableOfContentItem]) {
        removeAllSubviews()
        var cache: [UILabel] = labels.reversed()
        labels.removeAll()
        
        for data in content {
           
            let label = cache.popLast() ?? createLabel()
            label.attributedText = makeAttributedText(for: data.title)
            label.addTapGesture { _ in
                // TODO: Add scroll to header
            }
            
            addSubview(label) {
                $0.trailing.equal(to: trailingAnchor)
                $0.leading.equal(to: leadingAnchor, constant: Constants.levelLeftOffset * CGFloat(data.level))
                if let prevBottomAnchor = labels.last?.bottomAnchor {
                    $0.top.equal(to: prevBottomAnchor, constant: Constants.verticalInnerInset)
                } else {
                    $0.top.equal(to: topAnchor, constant: Constants.verticalBoundsInset)
                }
            }
            labels.append(label)
        }
        
        labels.last?.layoutUsing.anchors { $0.bottom.equal(to: bottomAnchor, constant: -Constants.verticalBoundsInset, priority: .defaultLow) }
        configuration?.blockSetNeedsLayout()
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }
    
    private func makeAttributedText(for string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.textSecondary,
            .foregroundColor: UIColor.textSecondary,
            .font: UIFont.calloutRegular
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return subviews.isEmpty ? Constants.emptySize : super.intrinsicContentSize
    }
}
