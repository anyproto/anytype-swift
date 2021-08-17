import UIKit

final class URLInputAccessoryView: DismissableInputAccessoryView {
    
    let urlInputView: URLInputView
    
    init(
        url: URL? = nil,
        didSetURL: @escaping (URL?) -> Void
    ) {
        self.urlInputView = URLInputView(
            url: url,
            didSetURL: didSetURL
        )
        super.init(frame: CGRect(
            origin: .zero,
            size: Constants.ulrInputAccessoryViewSize
            )
        )
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        addSubview(urlInputView)
        urlInputView.pinAllEdges(to: self)
    }
}

extension URLInputAccessoryView {
    
    enum Constants {
        static let ulrInputAccessoryViewSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: 56.5
        )
    }
}
