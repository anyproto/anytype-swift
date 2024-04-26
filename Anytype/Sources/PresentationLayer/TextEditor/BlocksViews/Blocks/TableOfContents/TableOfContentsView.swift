import Foundation
import UIKit
import Combine

final class TableOfContentsView: UIView, BlockContentView {
    
    // MARK: - Private properties
    
    private enum Constants {
        static let levelLeftOffset: CGFloat = 20
        static let verticalBoundsInset: CGFloat = 6
        static let verticalInnerInset: CGFloat = 12
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
    
    private func updateView(content: TableOfContentData) {
        removeAllSubviews()
        
        switch content {
        case let .items(items):
            showItems(items: items)
        case let .empty(title):
            showEmptyState(title: title)
        }
        
        configuration?.blockSetNeedsLayout()
    }
    
    private func showEmptyState(title: String) {
        let label: UILabel = createLabel()
        label.font = .calloutRegular
        label.textColor = .Text.tertiary
        label.text = title
        addSubview(label) {
            $0.pinToSuperview(insets: UIEdgeInsets(
                top: Constants.verticalBoundsInset,
                left: 0,
                bottom: Constants.verticalBoundsInset,
                right: 0
            ))
        }
    }
    
    private func showItems(items: [TableOfContentItem]) {
        
        var cache: [UILabel] = labels.reversed()
        labels.removeAll()
        
        for data in items {
           
            let label = cache.popLast() ?? createLabel()
            label.attributedText = makeAttributedText(for: data.title)
            label.addTapGesture { [weak self] _ in
                self?.configuration?.onTap(data.blockId)
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
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }
    
    private func makeAttributedText(for string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.Text.secondary,
            .foregroundColor: UIColor.Text.secondary,
            .font: UIFont.calloutRegular
        ])
    }
}
