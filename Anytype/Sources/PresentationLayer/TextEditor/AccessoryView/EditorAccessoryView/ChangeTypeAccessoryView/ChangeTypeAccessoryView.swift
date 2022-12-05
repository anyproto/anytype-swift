import UIKit
import Combine

class ChangeTypeAccessoryView: UIView {
    // https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5309%3A1717
    private struct Constants {
        static let padding: CGFloat = 16
        static let topViewHeight: CGFloat = 48
        static let doneButtonWidth: CGFloat = 45
        static let expandedHeight: CGFloat = 144
        static let minimizedHeight: CGFloat = 48
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
        backgroundColor = .backgroundPrimary

        addSubview(stackView) {
            $0.pinToSuperviewPreservingReadability() 
        }

        topView.addSubview(doneButton) {
            $0.trailing.equal(to: topView.trailingAnchor, constant: -Constants.padding)
            $0.centerY.equal(to: topView.centerYAnchor)
            $0.width.lessThanOrEqual(to: Constants.doneButtonWidth)
        }

        topView.layoutUsing.anchors {
            $0.height.equal(to: Constants.topViewHeight)
        }

        topView.addSubview(changeButton) {
            $0.leading.equal(to: topView.leadingAnchor, constant: Constants.padding)
            $0.centerY.equal(to: topView.centerYAnchor)
        }

        let dividerView = UIView()
        dividerView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        dividerView.backgroundColor = .strokePrimary

        stackView.axis = .vertical
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(changeTypeView)

        let changeTypeViewHeightConstraint = changeTypeView.heightAnchor.constraint(equalToConstant: 96)
        changeTypeViewHeightConstraint.isActive = true
        changeTypeViewHeightConstraint.priority = .init(rawValue: 999)

        changeTypeView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        let changeTypeAction = UIAction { [weak viewModel] _ in
            viewModel?.toggleChangeTypeState()
        }


        changeButton.addAction(changeTypeAction, for: .touchUpInside)
    }

    private func bindViewModel() {
        let heightConstraint = heightAnchor.constraint(equalToConstant: Constants.expandedHeight)
        heightConstraint.isActive = true

        viewModel.$isTypesViewVisible.sink { [weak self] isVisible in
            // For some known reason swiftUI view can't layout itself because its position is under the keyboard in an initialization moment. Use static height values is an workaround
            heightConstraint.constant = isVisible ? Constants.expandedHeight : Constants.minimizedHeight

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

        button.setTitle(Loc.done, for: .normal)
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
        setTitle(Loc.changeType, for: .normal)
        setImage(UIImage(asset: .TextEditor.turnIntoArrow), for: .normal)
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

        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.imageView?.transform = transform
        }
    }
}
