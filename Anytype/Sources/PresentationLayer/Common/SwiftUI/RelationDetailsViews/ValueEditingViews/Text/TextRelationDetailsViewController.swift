import Foundation
import UIKit
import AnytypeCore

final class TextRelationDetailsViewController: UIViewController {

    private let titleLabel = makeTitleLabel()
    private let textView = makeTextView()
    
    private let viewModel: TextRelationDetailsViewModel
    
    // MARK: - Initializers
    
    init(viewModel: TextRelationDetailsViewModel) {
        self.viewModel = viewModel
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
    
}

private extension TextRelationDetailsViewController {
    
    static func makeTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.textPrimary
        titleLabel.font = AnytypeFont.uxTitle1Semibold.uiKitFont
        titleLabel.textAlignment = .center
        
        return titleLabel
    }
    
    static func makeTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder(frame: .zero, textContainer: nil) { _ in }
        textView.isScrollEnabled = false
        textView.font = AnytypeFont.uxBodyRegular.uiKitFont
        textView.textColor = UIColor.grayscale90
        
        return textView
    }
    
    func setupView() {
        titleLabel.text = viewModel.title
        setupTextView()
        setupLayout()
        
        if FeatureFlags.rainbowCells {
            view.fillSubviewsWithRandomColors()
        }
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
    
    func setupLayout() {
        view.addSubview(titleLabel) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: 48)
        }
        
        view.addSubview(textView) {
            $0.top.equal(to: titleLabel.bottomAnchor)
            $0.pinToSuperview(excluding: [.top])
        }
    }
    
}

extension TextRelationDetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.value = textView.text
    }
    
}
