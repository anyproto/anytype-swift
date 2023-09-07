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

        let dividerView = UIView()
        dividerView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        dividerView.backgroundColor = .Stroke.primary

        stackView.axis = .vertical
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(changeTypeView)

        // Fix swiftui animation
        changeTypeView.addSubview(changeTypeViewSource) {
            $0.pinToSuperview(excluding: [.bottom])
        }
        
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
                self?.changeButton.imageView?.transform = isVisible ? .identity : CGAffineTransform(rotationAngle: Double.pi)
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
        button.setTitleColor(UIColor.System.amber100, for: .normal)
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
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = attributedString(for: .normal)
        configuration.image = UIImage(asset: .TextEditor.turnIntoArrow)
        configuration.buttonSize = .mini
        configuration.titleAlignment = .leading
        configuration.imagePlacement = .leading
        configuration.contentInsets = .init(top: 0, leading: -5, bottom: 0, trailing: 0)
        configuration.imagePadding = 5
        self.configuration = configuration
        
        configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            
            var configuration = button.configuration
            configuration?.attributedTitle = attributedString(for: button.state)
            self.configuration = configuration
        }
    }
    
    private func attributedString(for state: UIButton.State) -> AttributedString {
        .init(
            Loc.changeType,
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.bodyRegular,
                NSAttributedString.Key.foregroundColor: state == .highlighted ? UIColor.Text.primary : UIColor.Button.active
            ])
        )
    }
}
