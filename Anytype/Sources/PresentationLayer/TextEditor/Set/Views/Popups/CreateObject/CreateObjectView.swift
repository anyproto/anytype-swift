import UIKit

final class CreateObjectView: UIView {
    enum Style {
        case `default`
        case bookmark
        
        var placeholder: String {
            switch self {
            case .default: return Loc.untitled
            case .bookmark: return Loc.Set.Bookmark.Create.placeholder
            }
        }
    }
    
    private let textField = UITextField()
    private let button: ButtonWithImage

    private let viewModel: any CreateObjectViewModelProtocol

    init(viewModel: some CreateObjectViewModelProtocol) {
        self.viewModel = viewModel

        switch viewModel.style {
        case .default:
            button = ButtonsFactory.makeButton(image: UIImage(asset: .setOpenToEdit))
        case .bookmark:
            button = ButtonsFactory.makeButton(text: Loc.create, textStyle: .body)
        }

        super.init(frame: .zero)

        setupButton()
        setupTextField()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    private func setupLayout() {
        layoutUsing.stack {
            $0.alignment = .center
            $0.edgesToSuperview(insets: .init(top: 0, left: 20, bottom: 0, right: 20))
        } builder: {
            $0.hStack(
                textField,
                $0.hGap(fixed: 8),
                button
            )
        }

        if viewModel.style == .default {
            button.widthAnchor.constraint(equalToConstant: 24).isActive = true
            button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = heightAnchor.constraint(equalToConstant: 68)
        heightConstraint.priority = .init(rawValue: 999)
        heightConstraint.isActive = true
    }

    private func setupButton() {
        button.addAction { [weak self] _ in
            guard let self = self else { return }

            self.viewModel.actionButtonTapped(with: self.textField.text ?? "")
        }
    }

    private func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.font = .previewTitle1Medium
        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.style.placeholder,
            attributes: [
                .font: UIFont.previewTitle1Medium,
                .foregroundColor: UIColor.Text.secondary
            ]
        )
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
    }

    @objc private func textDidChange(textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.textDidChange(text)
    }
}

extension CreateObjectView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.returnDidTap()
        return false
    }
}
