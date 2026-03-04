import UIKit
import AnytypeCore
import Combine

class CursorModeAccessoryView: UIView {
    private let viewModel: CursorModeAccessoryViewModel

    private var subscriptions = [AnyCancellable]()
    private var actionButtons = [Item: UIButton]()

    // MARK: - Lifecycle

    init(viewModel: CursorModeAccessoryViewModel) {
        self.viewModel = viewModel

        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        setupViews()
        bindViewModel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateGradientColors()
    }

    private func bindViewModel() {
        viewModel.$items.sink { [weak self] cells in
            self?.actionButtons.forEach { item, button in
                button.isHidden = !cells.contains(item)
            }
        }.store(in: &subscriptions)
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .Background.primary

        // ScrollView fills the entire view
        addSubview(scrollView) {
            $0.pinToSuperview()
        }

        // Done container (64px, white background) pinned to trailing
        addSubview(doneContainerView) {
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.width.equal(to: 64)
        }

        // Gradient (16px + 1px) fades scrolled content before the separator
        addSubview(gradientView) {
            $0.trailing.equal(to: doneContainerView.leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.width.equal(to: 17)
        }

        // Separator (1px) on top of gradient, to the left of done container
        addSubview(separatorView) {
            $0.trailing.equal(to: doneContainerView.leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.width.equal(to: 1)
        }

        // Done button fills the container (UIButton centers image by default)
        doneContainerView.addSubview(doneButton) {
            $0.pinToSuperview()
        }

        // Stack view inside scroll view
        scrollView.addSubview(stackView) {
            $0.pinToSuperview()
            $0.height.equal(to: scrollView.heightAnchor)
        }

        // Content insets: 16px leading, 81px trailing (64 done + 1 separator + 16 gradient)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 81)

        // Add action buttons
        Item.allCases.forEach { item in
            let button = makeActionButton(image: item.image) { [weak self] _ in
                UISelectionFeedbackGenerator().selectionChanged()
                self?.viewModel.handle(item.action)
            }
            actionButtons[item] = button
            stackView.addArrangedSubview(button)
        }

        // Done button action
        doneButton.addAction(UIAction { [weak self] _ in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.viewModel.handle(.keyboardDismiss)
        }, for: .touchUpInside)

        // Setup gradient
        gradientView.layer.addSublayer(gradientLayer)
        updateGradientColors()
    }

    // MARK: - Private methods

    private func makeActionButton(image: UIImage?, action: @escaping UIActionHandler) -> UIButton {
        let primaryAction = UIAction(handler: action)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .Control.secondary
        button.addAction(primaryAction, for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 32)
        ])

        return button
    }

    private func updateGradientColors() {
        let bgColor = UIColor.Background.primary
        gradientLayer.colors = [bgColor.withAlphaComponent(0).cgColor, bgColor.cgColor]
    }

    // MARK: - Views

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 24
        return stackView
    }()

    private let doneContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .Background.primary
        return view
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .Shape.transparentSecondary
        return view
    }()

    private let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(asset: .X32.Arrow.down), for: .normal)
        button.tintColor = .Control.secondary
        return button
    }()

    // MARK: - Unavailable

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
}
