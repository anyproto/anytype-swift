import Foundation
import Services
import AnytypeCore

protocol HomeWidgetsRegistryProtocol {
    func providers(blocks: [BlockInformation], widgetObject: BaseDocumentProtocol, output: CommonWidgetModuleOutput?) -> [HomeWidgetSubmoduleModel]
}

final class HomeWidgetsRegistry: HomeWidgetsRegistryProtocol {

    private struct ProviderCache {
        let widgetBlockId: String
        let widgetObjectId: String
        let layout: BlockWidget.Layout?
        let provider: HomeSubmoduleProviderProtocol
        let source: HomeWidgetProviderAssemblyProtocol
    }
    
    private enum Constants {
        static let binWidgetId = "BinWidgetId"
    }
    
    // MARK: - DI
    
    private let stateManager: HomeWidgetsStateManagerProtocol
    private var providersCache: [ProviderCache] = []
    
    init(
        stateManager: HomeWidgetsStateManagerProtocol
    ) {
        self.stateManager = stateManager
    }
    
    // MARK: - HomeWidgetsRegistryProtocol
    
    func providers(
        blocks: [BlockInformation],
        widgetObject: BaseDocumentProtocol,
        output: CommonWidgetModuleOutput?
    ) -> [HomeWidgetSubmoduleModel] {
        
        var newProvidersCache: [ProviderCache] = []
        
        let blockWidgets = blocks.compactMap { block -> ProviderCache? in
            guard let widgetInfo = widgetObject.widgetInfo(block: block),
                  let provider = providerForInfo(widgetInfo, widgetObject: widgetObject, output: output) else { return nil }
            
            return createProviderCache(
                source: provider,
                widgetBlockId: block.id,
                info: widgetInfo,
                widgetObject: widgetObject
            )
        }
        
        newProvidersCache.append(contentsOf: blockWidgets)
        
        providersCache = newProvidersCache
        return providersCache.map { HomeWidgetSubmoduleModel(blockId: $0.widgetBlockId, provider: $0.provider) }
    }
    
    // MARK: - Private
    
    private func createProviderCache(
        source: HomeWidgetProviderAssemblyProtocol,
        widgetBlockId: String,
        info: BlockWidgetInfo?,
        widgetObject: BaseDocumentProtocol
    ) -> ProviderCache {
        let cache = providersCache.first {
            $0.source === source
            && $0.widgetBlockId == widgetBlockId
            && $0.widgetObjectId == widgetObject.objectId
            && $0.layout == info?.fixedLayout
        }
        
        if let cache {
            return cache
        }
        
        let provider = source.make(widgetBlockId: widgetBlockId, widgetObject: widgetObject, stateManager: stateManager)
        
        let newCache = ProviderCache(
            widgetBlockId: widgetBlockId,
            widgetObjectId: widgetObject.objectId,
            layout: info?.fixedLayout,
            provider: provider,
            source: source
        )
        
        return newCache
    }
    
    private func providerForInfo(_ widgetInfo: BlockWidgetInfo, widgetObject: BaseDocumentProtocol, output: CommonWidgetModuleOutput?) -> HomeWidgetProviderAssemblyProtocol? {
        switch widgetInfo.source {
        case .object(let objectDetails):
            return providerForObject(objectDetails, widgetInfo: widgetInfo, widgetObject: widgetObject, output: output)
        case .library(let anytypeWidgetId):
            return providerForAnytypeWidgetId(anytypeWidgetId, widgetInfo: widgetInfo, widgetObject: widgetObject, output: output)
        }
    }
    
    private func providerForAnytypeWidgetId(_ anytypeWidgetId: AnytypeWidgetId, widgetInfo: BlockWidgetInfo, widgetObject: BaseDocumentProtocol, output: CommonWidgetModuleOutput?) -> HomeWidgetProviderAssemblyProtocol? {
        let widgetData = WidgetSubmoduleData(widgetBlockId: widgetInfo.id, widgetObject: widgetObject, stateManager: stateManager, output: output)
        switch (anytypeWidgetId, widgetInfo.fixedLayout) {
        case (.favorite, .tree):
            let view = FavoriteTreeWidgetsubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.favorite, .list):
            let view = FavoriteListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.favorite, .compactList):
            let view = FavoriteCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recent, .tree):
            let view = RecentEditTreeWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recent, .list):
            let view = RecentEditListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recent, .compactList):
            let view = RecentEditCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recentOpen, .tree):
            let view = RecentOpenTreeWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recentOpen, .list):
            let view = RecentOpenListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recentOpen, .compactList):
            let view = RecentOpenCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.sets, .tree):
            let view = SetsCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.sets, .list):
            let view = SetsListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.sets, .compactList):
            let view = SetsCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.collections, .tree):
            let view = CollectionsCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.collections, .list):
            let view = CollectionsListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.collections, .compactList):
            let view = CollectionsCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (_, .link):
            return nil
        }
    }
    
    private func providerForObject(_ objectDetails: ObjectDetails, widgetInfo: BlockWidgetInfo, widgetObject: BaseDocumentProtocol, output: CommonWidgetModuleOutput?) -> HomeWidgetProviderAssemblyProtocol? {
        
        guard objectDetails.isNotDeletedAndVisibleForEdit else { return nil }
        let widgetData = WidgetSubmoduleData(widgetBlockId: widgetInfo.id, widgetObject: widgetObject, stateManager: stateManager, output: output)
        switch widgetInfo.fixedLayout {
        case .link:
            let view = LinkWidgetView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case .tree:
            guard objectDetails.editorViewType == .page else { return nil }
            let view = ObjectTreeWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case .list:
            guard objectDetails.editorViewType == .set else { return nil }
            let view = SetObjectListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case .compactList:
            guard objectDetails.editorViewType == .set else { return nil }
            let view = SetObjectCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        }
    }
}
