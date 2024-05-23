import UIKit
import AnytypeCore

final class MarkupsViewController: UIViewController {

    private let backdropView = UIView()
    private(set) lazy var containerShadowView = RoundedShadowView(view: containerStackView, cornerRadius: 12)

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.distribution = .fillEqually

        return containerStackView
    }()

    private var topStackView: UIStackView = {
        let leftTopStackView = UIStackView()
        leftTopStackView.axis = .horizontal
        leftTopStackView.distribution = .fillEqually

        return leftTopStackView
    }()

    private var middleStackView: UIStackView = {
        let leftBottomStackView = UIStackView()
        leftBottomStackView.axis = .horizontal
        leftBottomStackView.distribution = .fillEqually

        return leftBottomStackView
    }()

    private var bottomStackView: UIStackView = {
        let leftStackView = UIStackView()
        leftStackView.axis = .horizontal
        leftStackView.distribution = .fillEqually

        return leftStackView
    }()
    
    private lazy var boldButton = makeButton(image: UIImage(asset: .TextStyles.bold)) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.bold))
    }

    private lazy var italicButton = makeButton(image: UIImage(asset: .TextStyles.italic)) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.italic))
    }

    private lazy var strikethroughButton = makeButton(image: UIImage(asset: .TextStyles.strikethrough)) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.strikethrough))
    }
    
    private lazy var underlineButton = makeButton(image: UIImage(asset: .TextStyles.underline)) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.underline))
    }

    private lazy var codeButton = makeButton(text: Loc.TextStyle.Code.title) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.keyboard))
    }

    private lazy var urlButton = makeButton(text: Loc.TextStyle.Link.title) { [weak self] in
        self?.viewModel.handle(action: .toggleMarkup(.link))
    }

    private lazy var leftAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: UIImage(asset: .TextStyles.Align.left))
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.left))
            UISelectionFeedbackGenerator().selectionChanged()
        }), for: .touchUpInside)
        return button
    }()
    private lazy var centerAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: UIImage(asset: .TextStyles.Align.center))
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.center))
            UISelectionFeedbackGenerator().selectionChanged()
        }), for: .touchUpInside)
        return button
    }()
    private lazy var rightAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: UIImage(asset: .TextStyles.Align.right))
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.right))
            UISelectionFeedbackGenerator().selectionChanged()
        }), for: .touchUpInside)
        return button
    }()
    private lazy var justifyAlignButton: ButtonWithImage = {
        let button = ButtonsFactory.makeButton(image: UIImage(asset: .TextStyles.Align.justify))
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handle(action: .selectAlignment(.justify))
            UISelectionFeedbackGenerator().selectionChanged()
        }), for: .touchUpInside)
        return button
    }()

    private let viewModel: MarkupViewModelProtocol
    private let viewDidCloseHandler: () -> Void

    // MARK: - Lifecycle
    init(viewModel: MarkupViewModelProtocol, viewDidClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.viewDidCloseHandler = viewDidClose
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
        containerStackView.backgroundColor = .Shape.primary

        containerShadowView.view.layer.cornerRadius = 12
        containerShadowView.view.layer.masksToBounds = true
        containerShadowView.shadowLayer.fillColor = UIColor.Shadow.primary.cgColor
        containerShadowView.shadowLayer.shadowRadius = 40

        view.backgroundColor = .clear
        backdropView.backgroundColor = .clear
        let tapGeastureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backdropViewTapped))
        backdropView.addGestureRecognizer(tapGeastureRecognizer)

        view.addSubview(backdropView)
        view.addSubview(containerShadowView)

        backdropView.pinAllEdges(to: view)

        containerStackView.addArrangedSubview(topStackView)
        containerStackView.addArrangedSubview(middleStackView)
        containerStackView.addArrangedSubview(bottomStackView)
        containerStackView.spacing = 1

        topStackView.addArrangedSubview(boldButton)
        topStackView.addArrangedSubview(italicButton)
        topStackView.addArrangedSubview(strikethroughButton)
        topStackView.addArrangedSubview(underlineButton)

        middleStackView.addArrangedSubview(codeButton)
        middleStackView.addArrangedSubview(urlButton)
        middleStackView.spacing = 1

        bottomStackView.addArrangedSubview(leftAlignButton)
        bottomStackView.addArrangedSubview(centerAlignButton)
        bottomStackView.addArrangedSubview(rightAlignButton)
        bottomStackView.addArrangedSubview(justifyAlignButton)

        codeButton.label.font = .uxBodyRegular
        codeButton.setTextColor(.Text.primary, state: .normal)
        codeButton.setTextColor(.Text.tertiary, state: .disabled)

        urlButton.label.font = .uxBodyRegular
        urlButton.setTextColor(.Text.primary, state: .normal)
        urlButton.setTextColor(.Text.tertiary, state: .disabled)
    }
    
    private func makeButton(
        image: UIImage? = nil,
        text: String? = nil,
        action: @escaping () -> Void
    ) -> ButtonWithImage {
        let button = ButtonsFactory.makeButton(image: image, text: text)
        button.addAction(UIAction(handler: { _ in
            action()
            UISelectionFeedbackGenerator().selectionChanged()
        }), for: .touchUpInside)
        return button
    }
    
    private func setup(button: ButtonWithImage, with state: AttributeState) {
        button.isEnabled = state != .disabled
        button.isSelected = state == .applied
    }

    @objc private func backdropViewTapped() {
       dismiss()
    }
}

extension MarkupsViewController: MarkupViewProtocol {
    
    func setMarkupState(_ state: MarkupViewsState) {
        DispatchQueue.main.async {
            self.setup(button: self.boldButton, with: state.markup[.bold, default: .disabled])
            self.setup(button: self.italicButton, with: state.markup[.italic, default: .disabled])
            self.setup(button: self.strikethroughButton, with: state.markup[.strikethrough, default: .disabled])
            self.setup(button: self.underlineButton, with: state.markup[.underline, default: .disabled])
            self.setup(button: self.codeButton, with: state.markup[.keyboard, default: .disabled])
            self.setup(button: self.urlButton, with: state.markup[.link, default: .disabled])
            
            self.setup(button: self.leftAlignButton, with: state.alignment[.left, default: .disabled])
            self.setup(button: self.centerAlignButton, with: state.alignment[.center, default: .disabled])
            self.setup(button: self.rightAlignButton, with: state.alignment[.right, default: .disabled])
            self.setup(button: self.justifyAlignButton, with: state.alignment[.justify, default: .disabled])
        }
    }
    
    func dismiss() {
        removeFromParentEmbed()
        viewDidCloseHandler()
    }
}
