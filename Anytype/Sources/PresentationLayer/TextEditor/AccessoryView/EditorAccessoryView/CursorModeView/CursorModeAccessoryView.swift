import UIKit
import Services
import AnytypeCore

class CursorModeAccessoryView: UIView {
    private let viewModel: CursorModeAccessoryViewModel

    // MARK: - Lifecycle

    init(viewModel: CursorModeAccessoryViewModel) {
        self.viewModel = viewModel

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews()
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .Background.primary
        addSubview(stackView) {
            if FeatureFlags.ipadIncreaseWidth {
                $0.pinToSuperview()
            } else {
                $0.pinToSuperviewPreservingReadability()
            }
        }
    }
    
    // MARK: - Public methods
    func setDelegate(_ delegate: CursorModeAccessoryViewDelegate) {
        viewModel.delegate = delegate
    }
    
    func update(info: BlockInformation, textView: UITextView, usecase: TextBlockUsecase) {
        viewModel.textView = textView
        viewModel.info = info
        
        updateMenuItems(info: info, usecase: usecase)
    }

    // MARK: - Private methods
    private func updateMenuItems(info: BlockInformation, usecase: TextBlockUsecase) {
        let items: [Item]
        if info.content.type == .text(.title) {
            items = [.style]
        } else {
            switch usecase {
            case .editor:
                items = [.slash, .style, .actions, .mention]
            case .simpleTable:
                items = [.style, .actions, .mention]
            }
        }
        
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        items.forEach { item in
            addBarButtonItem(image: item.image) { [weak self] _ in
                UISelectionFeedbackGenerator().selectionChanged()

                self?.viewModel.handle(item.action)
            }
        }

        addBarButtonItem(title: Loc.done) { [weak self] _ in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.viewModel.handle(.keyboardDismiss)
        }
    }

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
        // TODO: Refactoring with IOS-1317
        if image.isNotNil {
            button.tintColor = .Button.active
        }
        button.setTitle(title, for: .normal)
        button.setTitleColor(.Text.primary, for: .normal)
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
