import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkOnlyUrlView: UIView, BlockContentView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: BlockBookmarkOnlyUrlConfiguration) {
        apply(url: configuration.ulr)
    }
    
    private func setup() {
        backgroundColor = .backgroundPrimary
        
        addSubview(backgroundView) {
            $0.pinToSuperview(insets: Layout.bookmarkViewInsets)
            $0.height.equal(to: 48)
        }
        
        backgroundView.addSubview(urlView) {
            $0.pinToSuperview(excluding: [.top, .bottom], insets: Layout.contentInsets)
            $0.centerY.equal(to: backgroundView.centerYAnchor)
        }
    }
    
    private func apply(url: String) {        
        urlView.text = url
    }
    
    // MARK: - Views
    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.dynamicBorderColor = UIColor.strokePrimary
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let urlView: UILabel = {
        let view = UILabel()
        view.font = .relation3Regular
        view.textColor = .textSecondary
        view.backgroundColor = .backgroundPrimary
        return view
    }()
}

private extension BlockBookmarkOnlyUrlView {
    enum Layout {
        static let bookmarkViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        static let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
    }
}
