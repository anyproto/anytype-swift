import UIKit
import Combine

class DividerBlockContentView: UIView & UIContentView {
    
    private var subscription: AnyCancellable?
    
    // MARK: Views
    private var contentView: UIView = .init()
    private var dividerView: DividerBlockUIKitViewWithDivider = .init()
            
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
    
    func handle(_ state: DividerBlockUIKitView.State) {
        switch state.style {
        case .line: self.dividerView.toLineView()
        case .dots: self.dividerView.toDotsView()
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
    
    private func apply(configuration: DividerBlockContentConfiguration, forced: Bool) {
        if forced {
            self.currentConfiguration?.contextMenuHolder?.addContextMenuIfNeeded(self)
        }
    }
    
    private func apply(configuration: DividerBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else {
            self.apply(configuration: configuration, forced: true)
            return
        }
        
        self.currentConfiguration = configuration
        self.apply(configuration: configuration, forced: true)
        
        self.cleanupOnNewConfiguration()
        switch self.currentConfiguration.information.content {
        case let .divider(value):
            guard let style = DividerBlockUIKitView.StateConverter.asOurModel(value.style) else {
                return
            }
            self.handle(.init(style: style))
        default: return
        }
    }
}
