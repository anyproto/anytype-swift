import Services
import UIKit

enum TextBlockUsecase {
    case editor
    case simpleTable
}
struct TextViewAccessoryConfiguration {
    internal init(
        textView: UITextView,
        contentType: BlockContentType,
        usecase: TextBlockUsecase,
        output: AccessoryViewOutput?
    ) {
        self._textView = textView
        self.contentType = contentType
        self.usecase = usecase
        self.output = output
    }
    
    private weak var _textView: UITextView?
    var textView: UITextView { _textView ?? UITextView(frame: .zero) }
    let contentType: BlockContentType
    let usecase: TextBlockUsecase
    
    weak var output: AccessoryViewOutput?
}
