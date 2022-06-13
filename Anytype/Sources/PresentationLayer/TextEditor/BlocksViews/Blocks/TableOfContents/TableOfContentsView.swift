import Foundation
import UIKit

class TableOfContentsView: UIView, BlockContentView {
    
    private enum Constants {
        static let levelLeftOffset: CGFloat = 20
        static let verticalBoundsInset: CGFloat = 6
        static let verticalInnerInset: CGFloat = 12
    }
    
    private var labels = [UILabel]()
    
    func update(with configuration: TableOfContentsConfiguration) {
        let content = TableOfContentsSampleData.sampleData()
        
        removeAllSubviews()
        var cache: [UILabel] = labels.reversed()
        labels.removeAll()
        
        addLabels(content: content, level: 0, cache: &cache)
        labels.last?.layoutUsing.anchors { $0.bottom.equal(to: bottomAnchor, constant: Constants.verticalBoundsInset) }
    }
    
    // MARK: - Private
    
    private func addLabels(content: [TableOfContentsSampleData], level: Int, cache: inout [UILabel]) {
        for data in content {
           
            let label = cache.popLast() ?? createLabel()
            label.attributedText = makeAttributedText(for: data.title)
            label.addTapGesture { _ in
                print("label tap")
            }
            
            addSubview(label) {
                $0.trailing.equal(to: trailingAnchor)
                $0.leading.equal(to: leadingAnchor, constant: Constants.levelLeftOffset * CGFloat(level))
                if let prevBottomAnchor = labels.last?.bottomAnchor {
                    $0.top.equal(to: prevBottomAnchor, constant: Constants.verticalInnerInset)
                } else {
                    $0.top.equal(to: topAnchor, constant: Constants.verticalBoundsInset)
                }
            }
            labels.append(label)
            
            addLabels(content: data.children, level: level + 1, cache: &cache)
        }
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
}
