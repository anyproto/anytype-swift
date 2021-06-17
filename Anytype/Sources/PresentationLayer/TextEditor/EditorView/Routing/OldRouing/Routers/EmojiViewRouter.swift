import Foundation
import UIKit

class EmojiViewRouter {
    private weak var viewController: UIViewController?
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func handle(model: EmojiPicker.ViewModel) {
        let emojiController = EmojiPicker.ViewController(viewModel: model)
        viewController?.present(emojiController, animated: true, completion: nil)
    }
}
