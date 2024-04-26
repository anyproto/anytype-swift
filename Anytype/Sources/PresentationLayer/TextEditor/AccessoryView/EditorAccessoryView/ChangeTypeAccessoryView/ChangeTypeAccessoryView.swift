import UIKit
import Combine
import AnytypeCore

class ChangeTypeAccessoryView: UIView {
    // https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=5309%3A1717
    private struct Constants {
        static let padding: CGFloat = 16
        static let topViewHeight: CGFloat = 44
        static let typeviewHeight: CGFloat = 52
        static let doneButtonWidth: CGFloat = 45
        static let expandedHeight: CGFloat = 96
        static let minimizedHeight: CGFloat = 44
    }
    

    let viewModel: ChangeTypeAccessoryViewModel

    private let topView = UIView(frame: .zero)
    private let changeTypeViewSource: UIView
    private let changeTypeView = UIView()
    private lazy var stackView = UIStackView()
    private var cancellables = [AnyCancellable]()

    override var intrinsicContentSize: CGSize {
        stackView.sizeThatFits(.init(width: bounds.width, height: .greatestFiniteMagnitude))
    }

    init(viewModel: ChangeTypeAccessoryViewModel, changeTypeView: UIView) {
        self.viewModel = viewModel
        self.changeTypeViewSource = changeTypeView

        super.init(frame: .zero)

        setupViews()
        bindViewModel()
    }

    private func setupViews() {
        backgroundColor = .Background.primary

        addSubview(stackView) {
            $0.pinToSuperviewPreservingReadability(excluding: [.bottom])
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

        stackView.axis = .vertical
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(changeTypeView)

        // Fix swiftui animation
        changeTypeView.addSubview(changeTypeViewSource) {
            $0.pinToSuperview(excluding: [.bottom])
        }
        
        let changeTypeViewHeightConstraint = changeTypeView.heightAnchor.constraint(equalToConstant: Constants.typeviewHeight)
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

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                self?.changeTypeView.isHidden = !isVisible
                self?.changeButton.updateState(isOpen: isVisible)
                self?.stackView.layoutIfNeeded()
            }
        }.store(in: &cancellables)
    }

    // UI Elements
    private lazy var doneButton: UIButton = createDoneButton()

    private lazy var changeButton = ChangeButton(frame: .zero)

    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("Not been implemented") }
}
