import UIKit
import BlocksModels

final class URLInputAccessoryView: DismissableInputAccessoryView {
    private var model = Model.empty

    lazy var urlInputView: URLInputView = URLInputView(url: .none, didSetURL: { [weak self] url in
        guard let self = self else { return }
        let model = self.model
        
        self.handler.handleAction(
            .setLink(model.url, model.range),
            blockId: model.blockId
        )
        self.dismissHandler?()
    })
    private let handler: BlockActionHandlerProtocol
    
    init(handler: BlockActionHandlerProtocol) {
        self.handler = handler
        super.init(frame: CGRect(origin: .zero, size: Constants.ulrInputAccessoryViewSize))
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        addSubview(urlInputView)
        urlInputView.pinAllEdges(to: self)
    }
    
    func updateUrlData(_ model: Model) {
        self.model = model
        urlInputView.updateUrl(model.url)
    }
    
    override func becomeFirstResponder() -> Bool {
        urlInputView.textField.becomeFirstResponder()
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
