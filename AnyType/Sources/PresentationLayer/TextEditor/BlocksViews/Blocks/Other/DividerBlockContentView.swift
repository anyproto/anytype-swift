import UIKit
import Combine
import BlocksModels

class DividerBlockContentView: UIView & UIContentView {
    
    // MARK: Views
    private let contentView = UIView()
    private let dividerView = DividerBlockUIKitViewWithDivider()
            
    // MARK: Setup
    func setup() {
        self.setupUIElements()
        self.addLayout()
    }
    
    // MARK: UI Elements
    func setupUIElements() {
        // Default behavior
        [self.contentView, self.dividerView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
                    
        self.contentView.addSubview(self.dividerView)
        self.addSubview(self.contentView)
    }
    
    // MARK: Layout
    func addLayout() {
        if let superview = self.contentView.superview {
            let view = self.contentView
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }

        if let superview = self.dividerView.superview {
            let view = self.dividerView
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    func handle(_ state: BlockContent.Divider.Style) {
        switch state {
        case .line: dividerView.toLineView()
        case .dots: dividerView.toDotsView()
        }
    }
    
    /// Initialization
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// ContentView
    func cleanupOnNewConfiguration() {
        // do nothing or something?
    }
    
    var currentConfiguration: DividerBlockContentConfiguration!
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            /// apply configuration
            guard let configuration = newValue as? DividerBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }

    init(configuration: DividerBlockContentConfiguration) {
        super.init(frame: .zero)
        self.setup()
        self.apply(configuration: configuration)
    }
    
    private func apply(configuration: DividerBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else {
            return
        }
        self.currentConfiguration = configuration

        self.cleanupOnNewConfiguration()
        switch self.currentConfiguration.information.content {
        case let .divider(value):
            handle(value.style)
        default: return
        }
    }
}
