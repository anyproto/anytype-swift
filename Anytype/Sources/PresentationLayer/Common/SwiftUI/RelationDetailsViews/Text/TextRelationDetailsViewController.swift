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
    private let actionButton = UIButton(type: .custom)
    private let actionStackView = UIStackView()
    private var actionButtons: [ButtonHolder] = []
    
    private let viewModel: TextRelationDetailsViewModelProtocol
    
    private var textViewTrailingConstraint: NSLayoutConstraint?
    private var textViewBottomConstraint: NSLayoutConstraint?
    private var actionButtonLeadingConstraint: NSLayoutConstraint?
    
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
        if FeatureFlags.bookmarksFlow {
            for buttonHolder in actionButtons {
                buttonHolder.button.isEnabled = buttonHolder.viewModel.isActionAvailable
            }
        } else {
            if viewModel.actionButtonViewModel?.isActionAvailable ?? false {
                textViewTrailingConstraint?.isActive = false
                actionButtonLeadingConstraint?.isActive = true
                actionButton.isHidden = false
            } else {
                textViewTrailingConstraint?.isActive = true
                actionButtonLeadingConstraint?.isActive = false
                actionButton.isHidden = true
            }
        }
    }

}

// MARK: - Initial setup

private extension TextRelationDetailsViewController {
    
    static func makeTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.textPrimary
        titleLabel.font = AnytypeFont.uxTitle1Semibold.uiKitFont
        titleLabel.textAlignment = .center
        
        return titleLabel
    }
    
    static func makeTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder(frame: .zero, textContainer: nil)
        textView.isScrollEnabled = false
        textView.font = AnytypeFont.uxBodyRegular.uiKitFont
        textView.textColor = UIColor.textPrimary
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.backgroundColor = nil
        textView.linkTextAttributes = [:]
        
        return textView
    }
    
    func setupView() {
        titleLabel.text = viewModel.title
        setupTextView()
        if FeatureFlags.bookmarksFlow {
            setupActionButtons()
        } else {
            setupActionButton()
        }
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
                    .foregroundColor: UIColor.textTertiary
                ]
            )
        )
        
        textView.delegate = self
    }
    
    func setupActionButton() {
        guard let actionButtonViewModel = viewModel.actionButtonViewModel else {
            actionButton.isHidden = true
            return
        }
        
        actionButton.adjustsImageWhenHighlighted = false
        let image = UIImage(asset: actionButtonViewModel.iconAsset)?.withRenderingMode(.alwaysTemplate)
        actionButton.setImage(image, for: .normal)
        actionButton.tintColor = .buttonActive
        
        actionButton.addAction(
            UIAction(
                handler: { [weak self] _ in
                    self?.viewModel.actionButtonViewModel?.performAction()
                }
            ),
            for: .touchUpInside
        )
        actionButton.layer.cornerRadius = Constants.actionButtonSize.width / 2.0
        actionButton.layer.borderColor = UIColor.strokePrimary.cgColor
        actionButton.layer.borderWidth = 1
        
        actionButton.isHidden = !actionButtonViewModel.isActionAvailable
    }
    
    func setupLayout() {
        view.addSubview(titleLabel) {
            $0.height.equal(to: Constants.titleLabelHeight)
            $0.pinToSuperview(excluding: [.bottom])
        }
        
        if FeatureFlags.bookmarksFlow {
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
                self.textViewTrailingConstraint =  $0.trailing.equal(to: view.trailingAnchor)
            }
        } else {
            view.addSubview(textView) {
                $0.height.greaterThanOrEqual(to: Constants.textViewMinHeight)
                $0.top.equal(to: titleLabel.bottomAnchor)
                self.textViewBottomConstraint = $0.bottom.equal(to: view.bottomAnchor, constant: -Constants.textViewBottomInset)
                $0.leading.equal(to: view.leadingAnchor)
                self.textViewTrailingConstraint =  $0.trailing.equal(to: view.trailingAnchor)
            }
            view.addSubview(actionButton) {
                $0.centerY.equal(to: textView.centerYAnchor)
                $0.trailing.equal(to: view.trailingAnchor, constant: -Constants.actionButtonRightInset)
                self.actionButtonLeadingConstraint = $0.leading.equal(to: textView.trailingAnchor, activate: false)
                $0.size(Constants.actionButtonSize)
            }
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
            let actionButton = UIButton(type: .custom)
            let image = UIImage(asset: actionViewModel.iconAsset)?.withRenderingMode(.alwaysTemplate)
            actionButton.setImage(image, for: .normal)
            actionButton.tintColor = .buttonActive
            let text = NSAttributedString(
                string: actionViewModel.title,
                attributes: [
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.textPrimary
                ]
            )
            
            let disabledText = NSAttributedString(
                string: actionViewModel.title,
                attributes: [
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.textTertiary
                ]
            )
            actionButton.setAttributedTitle(text, for: .normal)
            actionButton.setAttributedTitle(disabledText, for: .disabled)
            actionButton.contentHorizontalAlignment = .leading
            actionButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
            actionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            
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
        static let actionButtonSize: CGSize = CGSize(width: 36, height: 36)
        static let actionButtonRightInset: CGFloat = 20
        static let actionButtonTopInset: CGFloat = 6
        static let actionButtonTitleInset: CGFloat = 8
    }
    
}
