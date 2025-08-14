import UIKit
import AnytypeCore
import Combine

class CursorModeAccessoryView: UIView {
    private let viewModel: CursorModeAccessoryViewModel
    
    private var subscriptions = [AnyCancellable]()

    // MARK: - Lifecycle

    init(viewModel: CursorModeAccessoryViewModel) {
        self.viewModel = viewModel

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$items.sink { [weak self] cells in
            Item.allCases.enumerated().forEach {
                self?.stackView.arrangedSubviews[$0.offset].isHidden = !cells.contains($0.element)
            }
        }.store(in: &subscriptions)
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .Background.primary
        addSubview(stackView) {
            $0.pinToSuperview()
        }
        
        Item.allCases.forEach { item in
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
    
    // MARK: - Private methods
    private func update(with items: [Item]) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
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
            button.tintColor = .Control.secondary
        }
        button.setTitle(title, for: .normal)
        button.setTitleColor(.Text.primary, for: .normal)
        
        if let title = button.titleLabel?.attributedText?.mutable {
            title.addAttribute(
                NSAttributedString.Key.kern,
                value: -0.41,
                range: NSRange(location: 0, length: title.length - 1)
            )
            button.titleLabel?.attributedText = title
        }
        
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
