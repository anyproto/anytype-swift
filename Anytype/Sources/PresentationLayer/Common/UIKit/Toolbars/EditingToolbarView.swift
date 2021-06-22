import UIKit

extension EditingToolbarView {
    typealias ActionHandler = (Action) -> Void

    /// Actions that emit toolbar on selection buttons
    enum Action {
        /// Slash button pressed
        case slashMenu
        /// Multiselect button pressed
        case multiActionMenu
        /// Done button pressed
        case keyboardDismiss
        /// Show bottom sheet style menu
        case showStyleMenu
        /// Show mention menu
        case mention
    }
}


/// [Design.](https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android-main-draft?node-id=3618%3A40)
class EditingToolbarView: UIView {
    // MARK: - Views

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually

        return stackView
    }()

    private var actionHandler: ActionHandler?

    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup views

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        addSubview(stackView)

        setupLayout()
    }

    private func setupLayout() {
        stackView.edgesToSuperview()
    
        addBarButtonItem(image: UIImage.edititngToolbar.addNew) { [weak self] _ in
            self?.actionHandler?(.slashMenu)
        }

        addBarButtonItem(image: UIImage.edititngToolbar.style) {[weak self] _ in
            self?.actionHandler?(.showStyleMenu)
        }
        
        addBarButtonItem(image: UIImage.edititngToolbar.mention) { [weak self] _ in
            self?.actionHandler?(.mention)
        }
        
        addBarButtonItem(title: "Done".localized) { [weak self]_ in
            self?.actionHandler?(.keyboardDismiss)
        }
    }

    // MARK: - Private methods

    /// Add bar item with title and image.
    /// - Parameters:
    ///   - title: Title. If nil a title is not displayed.
    ///   - image: Image. If nil a image is not displayed.
    ///   - action: Action performed on touch
    private func addBarButtonItem(title: String? = nil, image: UIImage? = nil, action: @escaping UIActionHandler) {
        let primaryAction = UIAction(handler: action)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.pureAmber, for: .normal)
        button.addAction(primaryAction, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }

    // MARK: - Public methods

    /// Set action handler to this toolbar
    /// - Parameter actionHandler: Handler that proccess toolbar actions
    func setActionHandler(_ actionHandler: @escaping ActionHandler) {
        self.actionHandler = actionHandler
    }
}
