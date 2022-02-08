import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkOnlyUrlView: UIView & UIContentView {
    private var currentConfiguration: BlockBookmarkOnlyUrlConfiguration
    
    init(configuration: BlockBookmarkOnlyUrlConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
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
        view.layer.borderColor = UIColor.strokePrimary.cgColor
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
    
    // MARK: - UIContentView
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockBookmarkOnlyUrlConfiguration,
                  configuration != currentConfiguration else { return }
            
            currentConfiguration = configuration
            apply(url: configuration.ulr)
        }
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("Not implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BlockBookmarkOnlyUrlView {
    enum Layout {
        static let bookmarkViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
        static let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
    }
}
