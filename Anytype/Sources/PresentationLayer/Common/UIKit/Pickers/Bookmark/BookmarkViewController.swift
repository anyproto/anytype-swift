
import UIKit
import Combine
import SwiftUI

final class BookmarkViewController: UIViewController {
    // MARK: Variables
    private let model: BookmarkToolbarViewModel
    
    // MARK: Initialization
    init(model: BookmarkToolbarViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUIElements() {
        let chosenData = self.model.chosenView()
        if let chosenView = chosenData.view {
            self.view.addSubview(chosenView)
            chosenView.translatesAutoresizingMaskIntoConstraints = false
            chosenView.edgesToSuperview()
        }
        if let payload = chosenData.payload {
            self.navigationItem.title = payload.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
    }
}
