import Foundation
import UIKit
import Combine
import SwiftUI
import os


class MultiSelectionPaneSelectAllBarButtonItem: UIBarButtonItem {

    /// Variables
    private var model: MultiSelectionPaneSelectAllViewModel
    private var userResponseSubscription: AnyCancellable?
    private var anySelectionSubscription: AnyCancellable?
    @Published var isAnySelection: Bool? = false

    /// Initialization
    init(viewModel: MultiSelectionPaneSelectAllViewModel) {
        self.model = viewModel
        super.init()
        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Actions
    private func update(response: MultiSelectionPaneSelectAllUserResponse) {
        switch response {
        case .isEmpty: self.isAnySelection = false
        case .nonEmpty: self.isAnySelection = true
        }
    }

    @objc func processOnClick() {
        self.process(self.isAnySelection == true ? .deselectAll : .selectAll)
    }
    private func process(_ action: MultiSelectionPaneSelectAllAction) {
        self.model.process(action: action)
    }

    /// Setup
    private func setupCustomization() {
        self.target = self
        self.action = #selector(processOnClick)
    }

    private func setupInteraction() {
        self.userResponseSubscription = self.model.userResponse.sink { [weak self] (value) in
            self?.update(response: value)
        }
        self.anySelectionSubscription = self.$isAnySelection.safelyUnwrapOptionals().sink { [weak self] (value) in
            let title = value ? "Unselect All" : "Select All"
            self?.title = title
        }
    }

    // MARK: Setup
    private func setup() {
        self.setupCustomization()
        self.setupInteraction()
    }
}
