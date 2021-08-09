import UIKit
import Amplitude


final class URLInputViewController: UIViewController {
    
    private var urlInputView: URLInputView?
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override var inputAccessoryView: UIView? {
        urlInputView
    }
    
    init(
        url: URL? = nil,
        allowEmptyURL: Bool = false,
        didCreateURL: @escaping (URL?) -> Void
    ) {
        super.init(nibName: nil, bundle: nil)
        urlInputView = URLInputView(
            url: url,
            allowEmptyURL: allowEmptyURL
        ) { [weak self] url in
            didCreateURL(url)
            self?.dismiss(animated: false)
        }
        urlInputView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.popupBookmarkMenu)

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
