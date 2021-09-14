import UIKit
import Amplitude


class EditorAccessoryView: UIView {
    let actionHandler: EditorAccessoryViewActionHandler

    // MARK: - Lifecycle

    init(
        items: [Item] = [.slash, .style, .mention],
        actionHandler: EditorAccessoryViewActionHandler
    ) {
        self.actionHandler = actionHandler

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews(items)
    }

    private func setupViews(_ items: [Item]) {
        autoresizingMask = .flexibleHeight
        backgroundColor = .backgroundPrimary
        addSubview(stackView)
        stackView.edgesToSuperview()

        updateMenuItems(items)
    }
    
    // MARK: - Public methods

    func updateMenuItems(_ items: [Item]) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        items.forEach { item in
            addBarButtonItem(image: item.image) { [weak self] _ in
                // Analytics
                Amplitude.instance().logEvent(item.analyticsEvent)

                self?.actionHandler.handle(item.action)
            }
        }

        addBarButtonItem(title: "Done".localized) { [weak self] _ in
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
    private func addBarButtonItem(
        title: String? = nil, image: UIImage? = nil, action: @escaping UIActionHandler
    ) {
        let primaryAction = UIAction(handler: action)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.pureAmber, for: .normal)
        button.addAction(primaryAction, for: .touchUpInside)
        stackView.addArrangedSubview(button)
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
    
    // MARK: - Unavailable
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
}
