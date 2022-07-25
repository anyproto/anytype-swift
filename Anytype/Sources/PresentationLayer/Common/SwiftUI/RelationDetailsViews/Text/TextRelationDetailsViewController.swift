import Foundation
import UIKit
import AnytypeCore

final class TextRelationDetailsViewController: UIViewController {

    private let titleLabel = makeTitleLabel()
    private let textView = makeTextView()
    private let actionButton = UIButton(type: .custom)
    
    private let viewModel: TextRelationDetailsViewModel
    
    private var textViewTrailingConstraint: NSLayoutConstraint?
    private var textViewBottomConstraint: NSLayoutConstraint?
    private var actionButtonLeadingConstraint: NSLayoutConstraint?
    
    private let maxViewHeight: CGFloat
    
    // MARK: - Initializers
    
    init(viewModel: TextRelationDetailsViewModel) {
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
        setupActionButton()
        setupLayout()
        
        if FeatureFlags.rainbowViews {
            view.fillSubviewsWithRandomColors()
        }
        
        updateActionButtonVisibility()
    }
    
    func setupTextView() {
        textView.text = viewModel.value
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
        
        view.layoutUsing.anchors {
            $0.height.lessThanOrEqual(to: maxViewHeight)
        }
    }
    
}

// MARK: - UITextViewDelegate

extension TextRelationDetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.value = textView.text
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
    }
    
}
