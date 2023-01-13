import Foundation
import BlocksModels

protocol HomeWidgetsRegistryProtocol {
    func providers(blocks: [BlockInformation], widgetObject: HomeWidgetsObjectProtocol) -> [HomeWidgetProviderProtocol]
}

final class HomeWidgetsRegistry: HomeWidgetsRegistryProtocol {

    private struct ProviderCache {
        let widgetBlockId: String
        let widgetObjectId: String
        let provider: HomeWidgetProviderProtocol
        let source: HomeWidgetProviderAssemblyProtocol
    }
    
    private let treeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private var providersCache: [ProviderCache] = []
    
    init(treeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol, objectDetailsStorage: ObjectDetailsStorage) {
        self.treeWidgetProviderAssembly = treeWidgetProviderAssembly
        self.objectDetailsStorage = objectDetailsStorage
    }
    
    // MARK: - HomeWidgetsRegistryProtocol
    
    func providers(
        blocks: [BlockInformation],
        widgetObject: HomeWidgetsObjectProtocol
    ) -> [HomeWidgetProviderProtocol] {
        
        providersCache = blocks.compactMap { block in
            guard case let .widget(widget) = block.content else { return nil }
            switch widget.layout {
            case .link:
                
                guard let contentId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: block.id),
                      let contentDetails = objectDetailsStorage.get(id: contentId) else { return nil }
        
                switch contentDetails.editorViewType {
                case .page:
                    return createProviderCache(
                        source: treeWidgetProviderAssembly,
                        widgetBlockId: block.id,
                        widgetObject: widgetObject
                    )
                case .set:
                    return nil
                }
            case .tree:
                return createProviderCache(
                    source: treeWidgetProviderAssembly,
                    widgetBlockId: block.id,
                    widgetObject: widgetObject
                )
            }
        }
        
        return providersCache.map { $0.provider }
    }
    
    // MARK: - Private
    
    private func createProviderCache(
        source: HomeWidgetProviderAssemblyProtocol,
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol
    ) -> ProviderCache {
        let cache = providersCache.first {
            $0.source === source
            && $0.widgetBlockId == widgetBlockId
            && $0.widgetObjectId == widgetObject.objectId
        }
        
        if let cache {
            return cache
        }
        
        let provider = source.make(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
        
        let newCache = ProviderCache(
            widgetBlockId: widgetBlockId,
            widgetObjectId: widgetObject.objectId,
            provider: provider,
            source: source
        )
        
        return newCache
    }
}
