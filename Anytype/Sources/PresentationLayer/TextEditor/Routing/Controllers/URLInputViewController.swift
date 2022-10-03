import UIKit


final class URLInputViewController: UIViewController {
    
    private var urlInputView: URLInputView?
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override var inputAccessoryView: UIView? {
        urlInputView
    }
    
    init(
        url: AnytypeURL? = nil,
        didSetURL: @escaping (AnytypeURL?) -> Void
    ) {
        super.init(nibName: nil, bundle: nil)
        urlInputView = URLInputView(
            url: url
        ) { [weak self] url in
            didSetURL(url)
            self?.dismiss(animated: false)
        }
        urlInputView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        becomeFirstResponder()
        urlInputView?.textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(
                                    target: self,
                                    action: #selector(didTapOnEmptySpace)))
    }
    
    @objc private func didTapOnEmptySpace() {
        dismiss(animated: false)
    }
}
