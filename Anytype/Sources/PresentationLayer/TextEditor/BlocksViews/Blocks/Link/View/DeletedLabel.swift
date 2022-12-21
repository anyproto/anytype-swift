import UIKit

final class DeletedLabel: UIView {
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: deletedLabel.intrinsicContentSize.width + 8, height: UIView.noIntrinsicMetric)
    }
    
    private func setup() {
        addSubview(deletedLabel) {
            $0.pinToSuperview(
                insets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            )
        }
        
        backgroundColor = .strokeTertiary
        layer.cornerRadius = 3
    }
    
    private let deletedLabel: UILabel = {
        let view = UILabel()
        view.textColor = .TextNew.secondary
        view.font = .relation2Regular
        view.text = Loc.deleted
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
