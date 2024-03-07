import Foundation
import UIKit
import AnytypeCore

final class TextRelationDetailsViewController: UIViewController {

    private struct ButtonHolder {
        let button: UIButton
        let viewModel: TextRelationActionViewModelProtocol
    }
    
    private let titleLabel = makeTitleLabel()
    private let textView = makeTextView()
    private let actionStackView = UIStackView()
    private var actionButtons: [ButtonHolder] = []
    
    private let viewModel: TextRelationDetailsViewModelProtocol
    
    private var textViewBottomConstraint: NSLayoutConstraint?
    
    private let maxViewHeight: CGFloat
    
    // MARK: - Initializers
    
    init(viewModel: TextRelationDetailsViewModelProtocol) {
        self.viewModel = viewModel
        self.maxViewHeight = {
            guard let window = UIApplication.shared.keyWindow else {
                return UIScreen.main.bounds.height
            }
            
            let windowHeight: CGFloat = window.bounds.height
            let topPadding: CGFloat = window.safeAreaInsets.top
            
            return windowHeight - topPadding - AnytypePopup.Constants.grabberHeight
        }()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrided functions
    
    override func loadView() {
        super.loadView()
        setupView()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.updatePopupLayout(view.safeAreaLayoutGuide)
        _ = textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onWillDisappear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.isScrollEnabled = view.bounds.height.isEqual(to: maxViewHeight)
    }
    
}

extension TextRelationDetailsViewController {
    
    func keyboardDidUpdateHeight(_ height: CGFloat) {
        self.textViewBottomConstraint?.constant = -(height + Constants.textViewBottomInset)
    }
    
}

private extension TextRelationDetailsViewController {
    
    func updateActionButtonVisibility() {
        for buttonHolder in actionButtons {
            buttonHolder.button.isEnabled = buttonHolder.viewModel.isActionAvailable
        }
    }

}

// MARK: - Initial setup

private extension TextRelationDetailsViewController {
    
    static func makeTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.Text.primary
        titleLabel.font = AnytypeFont.uxTitle1Semibold.uiKitFont
        titleLabel.textAlignment = .center
        
        return titleLabel
    }
    
    static func makeTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder(frame: .zero, textContainer: nil)
        textView.isScrollEnabled = false
        textView.font = AnytypeFont.uxBodyRegular.uiKitFont
        textView.textColor = UIColor.Text.primary
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.backgroundColor = nil
        textView.linkTextAttributes = [:]
        
        return textView
    }
    
    func setupView() {
        titleLabel.text = viewModel.title
        setupTextView()
        setupActionButtons()
        setupLayout()
        
        if FeatureFlags.rainbowViews {
            view.fillSubviewsWithRandomColors()
        }
        
        updateActionButtonVisibility()
    }
    
    func setupTextView() {
        textView.text = viewModel.value
        textView.isEditable = viewModel.isEditable
        textView.keyboardType = viewModel.type.keyboardType
        textView.update(
            placeholder: NSAttributedString(
                string: viewModel.type.placeholder,
                attributes: [
                    .font: AnytypeFont.uxBodyRegular.uiKitFont,
                    .foregroundColor: UIColor.Text.tertiary
                ]
            )
        )
        
        textView.delegate = self
    }
    
    func setupLayout() {
        view.addSubview(titleLabel) {
            $0.height.equal(to: Constants.titleLabelHeight)
            $0.pinToSuperview(excluding: [.bottom])
        }
        view.addSubview(actionStackView) {
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            self.textViewBottomConstraint = $0.bottom.equal(to: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.textViewBottomInset)
        }
        view.addSubview(textView) {
            $0.height.greaterThanOrEqual(to: Constants.textViewMinHeight)
            $0.top.equal(to: titleLabel.bottomAnchor)
            $0.bottom.equal(to: actionStackView.topAnchor, constant: -Constants.actionButtonTitleInset)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
        
        view.layoutUsing.anchors {
            $0.height.lessThanOrEqual(to: maxViewHeight)
        }
    }
    
    private func setupActionButtons() {
        actionStackView.axis = .vertical
        actionStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        actionStackView.isLayoutMarginsRelativeArrangement = true
        if viewModel.actionsViewModel.isNotEmpty {
            actionStackView.addArrangedSubview(UIKitAnytypeDivider())
        }
        for actionViewModel in viewModel.actionsViewModel {
            let image = UIImage(asset: actionViewModel.iconAsset)
            let text = AttributedString(
                actionViewModel.title,
                attributes: AttributeContainer([
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.Text.primary
                ])
            )
            
            let disabledText = AttributedString(
                actionViewModel.title,
                attributes: AttributeContainer([
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.Text.tertiary
                ])
            )
            
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = text
            configuration.image = image
            configuration.buttonSize = .large
            configuration.titleAlignment = .leading
            configuration.imagePlacement = .leading
            configuration.contentInsets = .init(top: 14, leading: -8, bottom: 14, trailing: 0)
            configuration.imagePadding = 10

            let actionButton = UIButton(configuration: configuration)
            actionButton.configurationUpdateHandler = { button in
                var configuration = button.configuration
                switch button.state {
                case .disabled:
                    configuration?.attributedTitle = disabledText
                default:
                    configuration?.attributedTitle = text
                }
                
                button.configuration = configuration
            }
            
            actionButton.tintColor = .Button.active
            actionButton.contentHorizontalAlignment = .leading
            
            actionButton.addAction(
                UIAction(
                    handler: { _ in 
                        actionViewModel.performAction()
                    }
                ),
                for: .touchUpInside
            )
            
            actionStackView.addArrangedSubview(actionButton)
            actionStackView.addArrangedSubview(UIKitAnytypeDivider())
            actionButtons.append(ButtonHolder(button: actionButton, viewModel: actionViewModel))
        }
        actionStackView.addArrangedSubview(UIView())
    }
}

// MARK: - UITextViewDelegate

extension TextRelationDetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateValue(textView.text)
        updateActionButtonVisibility()
    }
    
}

// MARK: - Private extension

private extension TextRelationDetailsViewController {
    
    enum Constants {
        static let titleLabelHeight: CGFloat = 48
        static let textViewMinHeight: CGFloat = 48
        static let textViewBottomInset: CGFloat = 20
        static let actionButtonTitleInset: CGFloat = 8
    }
    
}
