import UIKit
import Combine

class ChangeTypeAccessoryView: UIView {
    // https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5309%3A1717
    private struct Constants {
        static let padding: CGFloat = 16
        static let topViewHeight: CGFloat = 48
        static let doneButtonWidth: CGFloat = 45
    }
    

    let viewModel: ChangeTypeAccessoryViewModel

    private let topView = UIView(frame: .zero)
    private let changeTypeView: UIView
    private lazy var stackView = UIStackView()
    private var cancellables = [AnyCancellable]()

    override var intrinsicContentSize: CGSize {
        stackView.sizeThatFits(.init(width: bounds.width, height: .greatestFiniteMagnitude))
    }

    init(viewModel: ChangeTypeAccessoryViewModel, changeTypeView: UIView) {
        self.viewModel = viewModel
        self.changeTypeView = changeTypeView

        super.init(frame: .zero)

        setupViews()
        bindViewModel()
    }

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .backgroundPrimary

        addSubview(stackView) {
            $0.pinToSuperview()
        }

        topView.addSubview(doneButton) {
            $0.trailing.equal(to: topView.trailingAnchor, constant: -Constants.padding)
            $0.centerY.equal(to: topView.centerYAnchor)
            $0.width.lessThanOrEqual(to: Constants.doneButtonWidth)
        }

        topView.layoutUsing.anchors {
            $0.height.equal(to: Constants.topViewHeight, priority: .defaultLow)
        }

        topView.addSubview(changeButton) {
            $0.leading.equal(to: topView.leadingAnchor, constant: Constants.padding)
            $0.centerY.equal(to: topView.centerYAnchor)
        }

        stackView.axis = .vertical
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(changeTypeView)

        let changeTypeAction = UIAction { [weak viewModel] _ in
            viewModel?.toggleChangeTypeState()
        }
        changeButton.addAction(changeTypeAction, for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.$isTypesViewVisible.sink { [weak self] isVisible in
            UIView.animate(withDuration: 0.2) {
                self?.changeTypeView.isHidden = !isVisible
                self?.stackView.layoutIfNeeded()
            }
        }.store(in: &cancellables)
    }

    // UI Elements
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        let primaryAction = UIAction { [weak self] _ in
            self?.viewModel.handleDoneButtonTap()
        }

        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(UIColor.System.amber, for: .normal)
        button.addAction(primaryAction, for: .touchUpInside)

        return button
    }()

    private lazy var changeButton = ChangeButton(frame: .zero)

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
        titleLabel?.font = .bodyRegular
        setTitleColor(.buttonActive, for: .normal)
        setTitleColor(.textPrimary, for: .highlighted)

        addTarget(self, action: #selector(didTap), for: .touchUpInside)

        imageEdgeInsets = .init(top: 0, left: -9, bottom: 0, right: 0)
    }

    @objc func didTap() {
        guard let transform = imageView?.transform.rotated(by: Double.pi) else {
            return
        }

        UIView.animate(withDuration: 0.4) {
            self.imageView?.transform = transform
        }
    }
}
