import UIKit

class MultiSelectionPaneDoneBarButtonItem: UIBarButtonItem {

    /// Variables
    private var model: MultiSelectionPaneDoneViewModel

    /// Initialization
    init(viewModel: MultiSelectionPaneDoneViewModel) {
        self.model = viewModel
        super.init()
        self.title = "Done"
        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Actions
    private func update(response: MultiSelectionPaneDoneUserResponse) {}

    @objc func processOnClick() {
        self.process(.done)
    }
    private func process(_ action: MultiSelectionPaneDoneAction) {
        self.model.process(action: action)
    }
    
    /// Setup
    private func setupCustomization() {
        self.target = self
        self.action = #selector(processOnClick)
    }
    
    private func setupInteraction() {}
    
    private func setup() {
        self.setupCustomization()
        self.setupInteraction()
    }
}
