import Foundation
import Combine
import BlocksModels

final class WidgetContainerViewModel: ObservableObject {
    
    // MARK: - DI
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    
    // MARK: - State
    
    @Published var isExpanded: Bool = true
    @Published var isEditState: Bool = false
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.blockWidgetService = blockWidgetService
        self.stateManager = stateManager
        
        stateManager.isEditStatePublisher
            .assign(to: &$isEditState)
    }
    
    func onDeleteWidgetTap() {
        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: widgetBlockId
            )
        }
    }
    
    func onEditTap() {
        stateManager.setEditState(true)
    }
}
