import UIKit
import Amplitude
import BlocksModels
import Combine

class EditorAccessoryView: UIView {
    private struct Constants {
        static let padding: CGFloat = 16
        static let topViewHeight: CGFloat = 48
        static let expandedHeight: CGFloat = 144
        static let doneButtonWidth: CGFloat = 45
    }

    typealias MenuItem = EditorAccessory.MenuItem

    let viewModel: EditorAccessoryViewModel

    private let changeTypeView: UIView
    private lazy var menuItemsView = EditorMenuItemsView()
    private lazy var changeButton = ChangeButton(frame: .zero)
    private lazy var doneButton = UIButton()

    private lazy var topView = UIView()
    private lazy var stackView = UIStackView()

    private var cancellables = [AnyCancellable]()

    // MARK: - Lifecycle

    init(
        viewModel: EditorAccessoryViewModel,
        changeTypeView: UIView
    ) {
        self.viewModel = viewModel
        self.changeTypeView = changeTypeView

        super.init(frame: .zero)

        setupViews()
        bindViewModel()
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        addSubview(stackView) {
            $0.pinToSuperview()
        }

        topView.addSubview(doneButton) {
            $0.trailing.equal(to: topView.trailingAnchor, constant: -Constants.padding)
            $0.centerY.equal(to: topView.centerYAnchor)
            $0.width.lessThanOrEqual(to: Constants.doneButtonWidth)
        }

        topView.addSubview(menuItemsView) {
            $0.pin(to: topView, excluding: [.right])
            $0.trailing.equal(to: doneButton.leadingAnchor)
        }

        topView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true

        backgroundColor = .backgroundPrimary
        setupDoneButton()

        topView.addSubview(changeButton) {
            $0.leading.equal(to: topView.leadingAnchor, constant: Constants.padding)
            $0.centerY.equal(to: topView.centerYAnchor)
        }

        stackView.axis = .vertical
        stackView.addArrangedSubview(topView)

        stackView.addArrangedSubview(changeTypeView)

        menuItemsView.isHidden = true

        let changeTypeAction = UIAction { [weak viewModel] _ in
            viewModel?.toogleChangeTypeState()
        }
        changeButton.addAction(changeTypeAction, for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.$isTypesViewVisible.sink { [weak self] isVisible in
            self?.changeButton.isSelected = isVisible

            UIView.animate(withDuration: 0.2) {
                self?.changeTypeView.isHidden = !isVisible
                self?.stackView.layoutIfNeeded()
            }
        }.store(in: &cancellables)

        viewModel.$isChangeTypeAvailable.sink { isAvailable in
            self.changeButton.isHidden = !isAvailable
            self.menuItemsView.isHidden = isAvailable
        }.store(in: &cancellables)
    }

    override var intrinsicContentSize: CGSize {
        stackView.sizeThatFits(.init(width: bounds.width, height: .greatestFiniteMagnitude))
    }
    
    // MARK: - Public methods
    func update(block: BlockModelProtocol, textView: CustomTextView) {
        viewModel.customTextView = textView
        viewModel.block = block
        
        updateMenuItems(information: block.information)
    }

    // MARK: - Private methods
    private func updateMenuItems(information: BlockInformation) {
        let menuItems: [MenuItem.MenuItemType]
        if information.content.type == .text(.title) {
            menuItems = [.style]
        } else {
            menuItems = [.slash, .style, .mention]
        }

        let items = menuItems.map { item -> MenuItem in
            MenuItem(
                action: { [weak viewModel] in viewModel?.handleMenuItemTap(item) },
                type: item
            )
        }

        menuItemsView.update(with: items)
    }

    private func setupDoneButton() {
        let primaryAction = UIAction { [weak self] _ in
            self?.viewModel.handleDoneButtonTap()
        }

        doneButton.setTitle("Done".localized, for: .normal)
        doneButton.setTitleColor(.pureAmber, for: .normal)
        doneButton.addAction(primaryAction, for: .touchUpInside)
    }

    // MARK: - Unavailable
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
}

private final class ChangeButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        setTitle("Change type".localized, for: .normal)
        setImage(.codeBlock.arrow, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .bodyRegular
        setTitleColor(.grayscale50, for: .normal)
        imageEdgeInsets = .init(top: 0, left: -9, bottom: 0, right: 0)
    }

    override var isSelected: Bool {
        didSet {
            guard let transform = imageView?.transform.rotated(by: Double.pi) else {
                return
            }

            UIView.animate(withDuration: 0.4) {
                self.imageView?.transform = transform
            }
        }
    }
}
