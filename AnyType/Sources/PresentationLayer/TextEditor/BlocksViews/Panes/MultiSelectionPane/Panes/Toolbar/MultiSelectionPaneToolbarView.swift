import UIKit
import Combine

extension MultiSelectionPane.Panes {
    enum Toolbar {}
}

// MARK: Action
enum MultiSelectionPaneToolbarAction {
    case turnInto(BlocksViews.UserAction.ToolbarOpenAction.BlockMenu)
    case delete
    case copy
}

// MARK: State
/// Internal State for View.
/// For example, if you press button which doesn't hide keyboard, by design, this button could be highlighted.
///
enum MultiSelectionPaneToolbarUserResponse {
    case isEmpty
    case nonEmpty(count: UInt, turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes])
}

final class MultiSelectionPaneToolbarView: UIView {
    private let insets: UIEdgeInsets
    private var turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes]?
    private let style: BlockTextView.Style = .default
    private let model: MultiSelectionPaneToolbarViewModel
    private var subscription: AnyCancellable?

    // MARK: Initialization
    init(frame: CGRect,
         applicationWindowInsetsProvider: ApplicationWindowInsetsProvider = UIApplication.shared) {
        self.insets = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: applicationWindowInsetsProvider.mainWindowInsets.bottom,
            right: 10
        )
        
        self.model = .init()
        super.init(frame: frame)
        self.setup()
    }
    
    init(
        viewModel: MultiSelectionPaneToolbarViewModel,
        applicationWindowInsetsProvider: ApplicationWindowInsetsProvider = UIApplication.shared
    ) {
        self.model = viewModel
        self.insets = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: applicationWindowInsetsProvider.mainWindowInsets.bottom,
            right: 10
        )
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    private func update(response: MultiSelectionPaneToolbarUserResponse) {
        switch response {
        case .isEmpty:
            self.titleLabel.text = NSLocalizedString("Select or drag and drop blocks", comment: "")
            self.turnIntoButton.isHidden = true
            self.copyButton.isHidden = true
            self.deleteButton.isHidden = true
        case let .nonEmpty(count, turnIntoStyles):
            self.titleLabel.text = String(count) + " " + NSLocalizedString("Blocks selected", comment: "")
            self.turnIntoButton.isHidden = turnIntoStyles.isEmpty
            self.copyButton.isHidden = false
            self.deleteButton.isHidden = false
            self.turnIntoStyles = turnIntoStyles
        }
    }

    // MARK: Public API Configurations
    // something that we should put in public api.

    private func setupCustomization() {
        self.backgroundColor = self.style.backgroundColor()

        for button in [self.turnIntoButton, self.deleteButton, self.copyButton] {
            button?.tintColor = self.style.normalColor()
        }
        self.turnIntoButton.addAction(UIAction(handler: { [weak self] _ in
            var filtering = BlocksViews.UserAction.ToolbarOpenAction.BlockMenu.Payload.Filtering()
            filtering.append(self?.turnIntoStyles ?? [])
            self?.model.process(action: .turnInto(.init(payload: .init(filtering: filtering))))
        }), for: .touchUpInside)
        self.deleteButton.addAction(UIAction(handler: { [weak self] _ in
            self?.model.process(action: .delete)
        }), for: .touchUpInside)
        self.copyButton.addAction(UIAction(handler: { [weak self] _ in
            self?.model.process(action: .copy)
        }), for: .touchUpInside)
    }

    private func setupInteraction() {
        self.subscription = self.model.userResponse.sink { [weak self] (value) in
            self?.update(response: value)
        }
    }

    // MARK: Setup
    private func setup() {
        self.setupUIElements()
        self.setupCustomization()
        self.setupInteraction()
    }

    // MARK: UI Elements
    private var titleLabel: UILabel!
    private var turnIntoButton: UIButton!
    private var deleteButton: UIButton!
    private var copyButton: UIButton!

    // MARK: Setup UI Elements
    private func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel = {
            let view = UILabel()
            view.textColor = .accentItemColor
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.turnIntoButton = {
            let view = UIButton(type: .system)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setImage(UIImage(named: "TextEditor/Panes/MultiSelection/Toolbar/TurnInto"), for: .normal)
            return view
        }()

        self.deleteButton = {
            let view = UIButton(type: .system)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setImage(UIImage(named: "TextEditor/Panes/MultiSelection/Toolbar/Delete"), for: .normal)
            return view
        }()

        self.copyButton = {
            let view = UIButton(type: .system)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setImage(UIImage(named: "TextEditor/Panes/MultiSelection/Toolbar/More"), for: .normal)
            return view
        }()
        
        let flexibleView = UIView()
        flexibleView.translatesAutoresizingMaskIntoConstraints = false
        flexibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        flexibleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stackView = UIStackView(arrangedSubviews: [self.titleLabel,
                                                       flexibleView,
                                                       self.turnIntoButton,
                                                       self.deleteButton,
                                                       self.copyButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally

        self.addSubview(stackView)
        stackView.edgesToSuperview(insets: insets)
    }
}
