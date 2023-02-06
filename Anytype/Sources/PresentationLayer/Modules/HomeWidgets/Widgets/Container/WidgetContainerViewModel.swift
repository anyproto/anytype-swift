import Foundation
import Combine
import BlocksModels

final class WidgetContainerViewModel: ObservableObject {
    
    // MARK: - DI
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    
    // MARK: - State
    
    @Published var isExpanded: Bool {
        didSet { saveExpandedState() }
    }
    @Published var isEditState: Bool = false
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.blockWidgetService = blockWidgetService
        self.stateManager = stateManager
        self.blockWidgetExpandedService = blockWidgetExpandedService
        
        isExpanded = blockWidgetExpandedService.isExpanded(widgetBlockId: widgetBlockId)
        
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
    
    // MARK: - Private
    
    private func saveExpandedState() {
        blockWidgetExpandedService.setState(widgetBlockId: widgetBlockId, isExpanded: isExpanded)
    }
}
