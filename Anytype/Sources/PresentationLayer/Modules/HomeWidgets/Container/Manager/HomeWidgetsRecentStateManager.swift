import Foundation
import Services

protocol HomeWidgetsRecentStateManagerProtocol: AnyObject {
    func setupRecentStateIfNeeded(
        blocks: [BlockInformation],
        widgetObject: some BaseDocumentProtocol
    )
}

final class HomeWidgetsRecentStateManager: HomeWidgetsRecentStateManagerProtocol {
    
    // MARK: - DI
    @Injected(\.loginStateService)
    private var loginStateService: any LoginStateServiceProtocol
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol
    
    // MARK: - State
    
    private var stateInstalled: Bool = false
    
    init() { }
    
    // MARK: - HomeWidgetsRecentStateManagerProtocol
    
    func setupRecentStateIfNeeded(
        blocks: [BlockInformation],
        widgetObject: some BaseDocumentProtocol
    ) {
        guard loginStateService.isFirstLaunchAfterAuthorization || loginStateService.isFirstLaunchAfterRegistration,
              !stateInstalled
            else { return }
        
        blocks.forEach { block in
            guard let widgetInfo = widgetObject.widgetInfo(block: block),
                  widgetInfo.source == .library(.recent) else { return }
            
            expandedService.setState(id: block.id, isExpanded: false)
        }
        stateInstalled = true
    }
}
