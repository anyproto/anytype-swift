import FloatingPanel
import UIKit


final class MarkupsViewController: UIViewController {

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.distribution = .fillProportionally
        containerStackView.spacing = 8.0

        return containerStackView
    }()

    private var leftTopStackView: UIStackView = {
        let leftTopStackView = UIStackView()
        leftTopStackView.axis = .horizontal
        leftTopStackView.distribution = .fillEqually
        leftTopStackView.spacing = 8.0

        return leftTopStackView
    }()

    private var leftBottomStackView: UIStackView = {
        let leftBottomStackView = UIStackView()
        leftBottomStackView.axis = .horizontal
        leftBottomStackView.distribution = .fillEqually

        return leftBottomStackView
    }()

    private var leftStackView: UIStackView = {
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.distribution = .fillEqually
        leftStackView.spacing = 16.0

        return leftStackView
    }()

    private var rightStackView: UIStackView = {
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.distribution = .fillEqually
        rightStackView.spacing = 16.0

        return rightStackView
    }()
    
    private lazy var boldButton = makeRoundedButton(image: .textAttributes.bold) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.bold))
    }
    private lazy var italicButton = makeRoundedButton(image: .textAttributes.italic) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.italic))
    }
    private lazy var strikethroughButton = makeRoundedButton(image: .textAttributes.strikethrough) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.strikethrough))
    }
    private lazy var codeButton = makeRoundedButton(image: .textAttributes.code) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.keyboard))
    }
    private lazy var urlButton = makeRoundedButton(image: .textAttributes.url, action: {})
    private lazy var leftAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .textAttributes.alignLeft)
        button.addBorders(edges: .right, width: 1.0, color: .grayscale30)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.left))
        }), for: .touchUpInside)
        return button
    }()
    private lazy var centerAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .textAttributes.alignCenter)
        button.addBorders(edges: .right, width: 1.0, color: UIColor.grayscale30)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.center))
        }), for: .touchUpInside)
        return button
    }()
    private lazy var rightAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: .textAttributes.alignRight)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.right))
        }), for: .touchUpInside)
        return button
    }()

    private let viewModel: MarkupViewModelProtocol

    // MARK: - Lifecycle
    init(viewModel: MarkupViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        viewModel.viewLoaded()
    }

    // MARK: -  Setup views

    private func setupViews() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStackView)

        containerStackView.addArrangedSubview(leftStackView)
        containerStackView.addArrangedSubview(rightStackView)

        containerStackView.edgesToSuperview(insets: UIEdgeInsets(top: 24.0, left: 16, bottom: 20, right: 16))

        setupLeftStackView()
        setupRightStackView()
    }

    private func setupLeftStackView() {
        setupLeftTopStackView()
        setupLeftBottomStackView()
        leftStackView.addArrangedSubview(leftTopStackView)
        leftStackView.addArrangedSubview(leftBottomStackView)
    }

    private func setupRightStackView() {
        rightStackView.addArrangedSubview(codeButton)
        rightStackView.addArrangedSubview(urlButton)
    }

    private func setupLeftTopStackView() {
        leftTopStackView.addArrangedSubview(boldButton)
        leftTopStackView.addArrangedSubview(italicButton)
        leftTopStackView.addArrangedSubview(strikethroughButton)
    }
    
    private func makeRoundedButton(
        image: UIImage?,
        action: @escaping () -> Void
    ) -> ButtonWithImage {
        let button = ButtonsFactory.roundedBorderуButton(image: image)
        button.addAction(UIAction(handler: { _ in
            action()
        }), for: .touchUpInside)
        return button
    }

    private func setupLeftBottomStackView() {
        leftBottomStackView.addArrangedSubview(leftAlignButton)
        leftBottomStackView.addArrangedSubview(centerAlignButton)
        leftBottomStackView.addArrangedSubview(rightAlignButton)

        leftBottomStackView.layer.borderWidth = 1.0
        leftBottomStackView.clipsToBounds = true
        leftBottomStackView.layer.cornerRadius = 10
        leftBottomStackView.layer.borderColor = UIColor.grayscale30.cgColor
    }
    
    private func setup(button: ButtonWithImage, with state: MarkupState) {
        button.isEnabled = state != .disabled
        button.isSelected = state == .applied
    }
}

extension MarkupsViewController: MarkupViewProtocol {
    
    func setMarkupState(_ state: AllMarkupsState) {
        DispatchQueue.main.async {
            self.setup(button: self.boldButton, with: state.bold)
            self.setup(button: self.italicButton, with: state.italic)
            self.setup(button: self.strikethroughButton, with: state.strikethrough)
            self.setup(button: self.codeButton, with: state.codeStyle)
            self.urlButton.isEnabled = false

            self.setup(button: self.leftAlignButton, with: state.alignment[.left, default: .disabled])
            self.setup(button: self.centerAlignButton, with: state.alignment[.center, default: .disabled])
            self.setup(button: self.rightAlignButton, with: state.alignment[.right, default: .disabled])
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}

extension MarkupsViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ fpc: FloatingPanelController,
                       shouldRemoveAt location: CGPoint,
                       with velocity: CGVector) -> Bool {
        let surfaceOffset = fpc.surfaceLocation.y - fpc.surfaceLocation(for: .full).y
        // If panel moved more than a half of its hight than hide panel
        if fpc.surfaceView.bounds.height / 2 < surfaceOffset {
            return true
        }
        return false
    }
}
