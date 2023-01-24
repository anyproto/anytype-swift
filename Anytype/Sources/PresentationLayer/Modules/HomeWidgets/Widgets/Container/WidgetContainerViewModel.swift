import Foundation
import Combine
final class WidgetContainerViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let stateManager: HomeWidgetsStateManagerProtocol
    
    // MARK: - State
    
    @Published var isExpanded: Bool = true
    @Published var isEditState: Bool = false
    
    init(stateManager: HomeWidgetsStateManagerProtocol) {
        self.stateManager = stateManager
        
        stateManager.isEditStatePublisher
            .assign(to: &$isEditState)
    }
}
