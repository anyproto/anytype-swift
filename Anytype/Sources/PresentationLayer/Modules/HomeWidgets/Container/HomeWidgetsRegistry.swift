import Foundation
import BlocksModels

protocol HomeWidgetsRegistryProtocol {
    func providers(blocks: [BlockInformation], widgetObject: HomeWidgetsObjectProtocol) -> [HomeWidgetProviderProtocol]
}

final class HomeWidgetsRegistry: HomeWidgetsRegistryProtocol {

    private let treeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    
    init(treeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol, objectDetailsStorage: ObjectDetailsStorage) {
        self.treeWidgetProviderAssembly = treeWidgetProviderAssembly
        self.objectDetailsStorage = objectDetailsStorage
    }
    
    // MARK: - HomeWidgetsRegistryProtocol
    
    func providers(blocks: [BlockInformation], widgetObject: HomeWidgetsObjectProtocol) -> [HomeWidgetProviderProtocol] {
        return blocks.compactMap { block in
            guard case let .widget(widget) = block.content else { return nil }
            switch widget.layout {
            case .link:
                
                guard let contentId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: block.id),
                      let contentDetails = objectDetailsStorage.get(id: contentId) else { return nil }
        
                switch contentDetails.editorViewType {
                case .page:
                    return treeWidgetProviderAssembly.make(widgetBlockId: block.id, widgetObject: widgetObject)
                case .set:
                    return nil
                }
            case .tree:
                return treeWidgetProviderAssembly.make(widgetBlockId: block.id, widgetObject: widgetObject)
            }
        }
    }
}
