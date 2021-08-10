import UIKit
import Amplitude


class EditorAccessoryView: UIView {
    enum Item {
        case mention
        case slash
        case style

        var image: UIImage {
            switch self {
            case .mention:
                return UIImage.edititngToolbar.mention
            case .slash:
                return UIImage.edititngToolbar.addNew
            case .style:
                return UIImage.edititngToolbar.style
            }
        }

        var action: EditorAccessoryViewAction {
            switch self {
            case .mention:
                return .mention
            case .slash:
                return .slashMenu
            case .style:
                return .showStyleMenu
            }
        }

        var analyticsEvent: String {
            switch self {
            case .mention:
                return AmplitudeEventsName.buttonMentionMenu
            case .slash:
                return AmplitudeEventsName.buttonSlashMenu
            case .style:
                return AmplitudeEventsName.buttonStyleMenu
            }
        }
    }

    // MARK: - Views

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually

        return stackView
    }()

    private let actionHandler: EditorAccessoryViewActionHandler
    private let items: [Item]

    // MARK: - Lifecycle

    init(items: [Item] = [.slash, .style, .mention], actionHandler: EditorAccessoryViewActionHandler) {
        self.actionHandler = actionHandler
        self.items = items

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }

    // MARK: - Setup views

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        addSubview(stackView)

        setupLayout()
    }

    private func setupLayout() {
        stackView.edgesToSuperview()

        items.forEach { item in
            addBarButtonItem(image: item.image) { [weak self] _ in
                // Analytics
                Amplitude.instance().logEvent(item.analyticsEvent)

                self?.actionHandler.handle(item.action)
            }
        }
        
        addBarButtonItem(title: "Done".localized) { [weak self]_ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.buttonHideKeyboard)

            self?.actionHandler.handle(.keyboardDismiss)
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
}
