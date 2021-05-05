import UIKit
import Combine
import BlocksModels

extension DividerBlockUIKitView {
    struct StateConverter {
        typealias Model = BlockContent.Divider.Style
        typealias OurModel = State.Style
        
        static func asModel(_ value: OurModel) -> Model? {
            switch value {
            case .line: return .line
            case .dots: return .dots
            }
        }
        
        static func asOurModel(_ value: Model) -> OurModel? {
            switch value {
            case .line: return .line
            case .dots: return .dots
            }
        }
    }
}

extension DividerBlockUIKitView {
    struct State {
        enum Style {
            case line, dots
        }
        
        var style: Style = .line
    }
}

class DividerBlockUIKitView: UIView {
    
    var subscription: AnyCancellable?
    
    // MARK: Views
    var contentView: UIView!
    var dividerView: DividerBlockUIKitViewWithDivider!
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    // MARK: Setup
    func setup() {
        self.setupUIElements()
        self.addLayout()
        self.handle(.init())
    }
    
    // MARK: UI Elements
    func setupUIElements() {
        // Default behavior
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.dividerView = {
            let view = DividerBlockUIKitViewWithDivider()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
                    
        self.contentView.addSubview(self.dividerView)
        self.addSubview(self.contentView)
    }
    
    // MARK: Layout
    func addLayout() {
        if let view = self.contentView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        if let view = self.dividerView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    func handle(_ state: State?) {
        switch state?.style {
        case .line: self.dividerView.toLineView()
        case .dots: self.dividerView.toDotsView()
        default: self.dividerView.toLineView()
        }
    }

    func configured(publisher: AnyPublisher<State?, Never>) -> Self {
        self.subscription = publisher.reciveOnMain().sink(receiveValue: { [weak self] (value) in
            self?.handle(value)
        })
        return self
    }
}
