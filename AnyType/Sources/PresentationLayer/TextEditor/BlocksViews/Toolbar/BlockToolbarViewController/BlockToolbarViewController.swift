
import UIKit
import Combine
import SwiftUI

final class BlockToolbarViewController: UIViewController {
    // MARK: Variables
    private let model: BlockToolbarViewModel
    
    // MARK: Subscriptions
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: Initialization
    init(model: BlockToolbarViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        model.dismissControllerPublisher.sink { [weak self] (value) in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &self.subscriptions)
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
