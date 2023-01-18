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
    private let setWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private var providersCache: [ProviderCache] = []
    
    init(
        treeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        objectDetailsStorage: ObjectDetailsStorage
    ) {
        self.treeWidgetProviderAssembly = treeWidgetProviderAssembly
        self.setWidgetProviderAssembly = setWidgetProviderAssembly
        self.objectDetailsStorage = objectDetailsStorage
    }
    
    // MARK: - HomeWidgetsRegistryProtocol
    
    func providers(
        blocks: [BlockInformation],
        widgetObject: HomeWidgetsObjectProtocol
    ) -> [HomeWidgetProviderProtocol] {
        
        providersCache = blocks.compactMap { block in
            guard case let .widget(widget) = block.content else { return nil }
            
            guard let contentId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: block.id),
                  let contentDetails = objectDetailsStorage.get(id: contentId) else { return nil }
            
            switch widget.layout {
            case .link:
                switch contentDetails.editorViewType {
                case .page:
                    return createProviderCache(
                        source: treeWidgetProviderAssembly,
                        widgetBlockId: block.id,
                        widgetObject: widgetObject
                    )
                case .set:
                    return createProviderCache(
                        source: setWidgetProviderAssembly,
                        widgetBlockId: block.id,
                        widgetObject: widgetObject
                    )
                }
            case .tree:
                switch contentDetails.editorViewType {
                case .page:
                    return createProviderCache(
                        source: treeWidgetProviderAssembly,
                        widgetBlockId: block.id,
                        widgetObject: widgetObject
                    )
                case .set:
                    return createProviderCache(
                        source: setWidgetProviderAssembly,
                        widgetBlockId: block.id,
                        widgetObject: widgetObject
                    )
                }
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
