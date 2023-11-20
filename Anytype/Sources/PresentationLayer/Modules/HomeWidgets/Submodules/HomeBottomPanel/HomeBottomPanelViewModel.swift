import Foundation
import Services
import Combine
import UIKit
import AnytypeCore

@MainActor
final class HomeBottomPanelViewModel: ObservableObject {
    
    // MARK: - Private properties
    
    private let stateManager: HomeWidgetsStateManagerProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    // MARK: - State
    
    private var dataSubscriptions: [AnyCancellable] = []
    
    // MARK: - Public properties
    
    @Published var isEditState: Bool = false
    
    init(
        stateManager: HomeWidgetsStateManagerProtocol,
        output: HomeBottomPanelModuleOutput?
    ) {
        self.stateManager = stateManager
        self.output = output
        setupDataSubscription()
    }
    
    func onTapAdd() {
        AnytypeAnalytics.instance().logAddWidget(context: .editor)
        output?.onCreateWidgetSelected(context: .editor)
    }
    
    func onTapDone() {
        stateManager.setEditState(false)
    }
    
    // MARK: - Private
    
    private func setupDataSubscription() {
        stateManager.isEditStatePublisher
            .receiveOnMain()
            .sink { [weak self] in self?.isEditState = $0 }
            .store(in: &dataSubscriptions)
    }
}
