import UIKit
import Amplitude


class EditorAccessoryView: UIView {
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

    // MARK: - Lifecycle

    init(actionHandler: EditorAccessoryViewActionHandler) {
        self.actionHandler = actionHandler
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
    
        addBarButtonItem(image: UIImage.edititngToolbar.addNew) { [weak self] _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.buttonActionMenu)

            self?.actionHandler.handle(.slashMenu)
        }

        addBarButtonItem(image: UIImage.edititngToolbar.style) {[weak self] _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.buttonStyleMenu)

            self?.actionHandler.handle(.showStyleMenu)
        }
        
        addBarButtonItem(image: UIImage.edititngToolbar.mention) { [weak self] _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.buttonMentionMenu)

            self?.actionHandler.handle(.mention)
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
