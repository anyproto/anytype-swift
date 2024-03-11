import Foundation
import Combine
import UIKit

// TODO: Refactoring editor view controller
final class EditorPageViewState: ObservableObject {
    
    private var cancellable : AnyCancellable? = nil
    
    let viewController: UIViewController
    var model: EditorPageViewModel
 
    init(viewController: UIViewController, model: EditorPageViewModel) {
        self.viewController = viewController
        self.model = model
        self.cancellable = model.objectWillChange.receiveOnMain().sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
}
