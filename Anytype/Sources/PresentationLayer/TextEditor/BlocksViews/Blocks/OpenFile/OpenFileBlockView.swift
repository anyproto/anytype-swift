import Combine
import Services
import UIKit
import AnytypeCore

class OpenFileBlockView: UIView, BlockContentView {
    private let label: AnytypeLabel = {
        let label = AnytypeLabel(style: .calloutRegular)
        label.textColor = .Text.primary
        label.setText(Loc.openFile)
        
        return label
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        
        view.layer.borderColor = UIColor.Shape.primary.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func update(with configuration: OpenFileBlockContentConfiguration) {
        apply(configuration: configuration)
    }
    
    private func setup() {
        addSubview(backgroundView) {
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor, constant: Layout.verticalPadding)
            $0.bottom.equal(to: bottomAnchor, constant: -Layout.verticalPadding)
        }
        
        backgroundView.addSubview(label) {
            $0.pinToSuperview(insets: UIEdgeInsets(
                top: Layout.verticalInset,
                left: Layout.horisontalInset,
                bottom: Layout.verticalInset,
                right: Layout.horisontalInset
            ))
        }
    }
    
    // MARK: - New configuration
    func apply(configuration: OpenFileBlockContentConfiguration) { }
}


extension OpenFileBlockView {
    private enum Layout {
        static let verticalInset: CGFloat = 7
        static let horisontalInset: CGFloat = 12
        static let verticalPadding: CGFloat = 16
    }
}
