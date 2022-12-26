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
                // TODO: Think different after implement sets
                guard let contentId = block.childrenIds.first,
                      let contentInfo = widgetObject.blockInformation(id: contentId),
                      case let .link(link) = contentInfo.content,
                      let contentDetails = objectDetailsStorage.get(id: link.targetBlockID) else { return nil }
        
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
