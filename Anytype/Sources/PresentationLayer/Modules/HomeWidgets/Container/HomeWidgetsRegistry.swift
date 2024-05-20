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
    // MARK: - List
    private let setListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let favoriteListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let recentEditListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let recentOpenListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let setsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let collectionsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    // MARK: - CompactList
    private let setsCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    
    private let stateManager: HomeWidgetsStateManagerProtocol
    private var providersCache: [ProviderCache] = []
    
    init(
        setListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        favoriteListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        recentEditListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        recentOpenListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        collectionsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setsCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) {
        self.setListWidgetProviderAssembly = setListWidgetProviderAssembly
        self.favoriteListWidgetProviderAssembly = favoriteListWidgetProviderAssembly
        self.recentEditListWidgetProviderAssembly = recentEditListWidgetProviderAssembly
        self.recentOpenListWidgetProviderAssembly = recentOpenListWidgetProviderAssembly
        self.setsListWidgetProviderAssembly = setsListWidgetProviderAssembly
        self.collectionsListWidgetProviderAssembly = collectionsListWidgetProviderAssembly
        self.setsCompactListWidgetProviderAssembly = setsCompactListWidgetProviderAssembly
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
            return favoriteListWidgetProviderAssembly
        case (.favorite, .compactList):
            let view = FavoriteCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recent, .tree):
            let view = RecentTreeWidgetSubmoduleView(data: widgetData, type: .recentEdit)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recent, .list):
            return recentEditListWidgetProviderAssembly
        case (.recent, .compactList):
            let view = RecentCompactListWidgetSubmoduleView(data: widgetData, type: .recentEdit)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recentOpen, .tree):
            let view = RecentTreeWidgetSubmoduleView(data: widgetData, type: .recentOpen)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.recentOpen, .list):
            return recentOpenListWidgetProviderAssembly
        case (.recentOpen, .compactList):
            let view = RecentCompactListWidgetSubmoduleView(data: widgetData, type: .recentOpen)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.sets, .tree):
            return setsCompactListWidgetProviderAssembly
        case (.sets, .list):
            return setsListWidgetProviderAssembly
        case (.sets, .compactList):
            return setsCompactListWidgetProviderAssembly
        case (.collections, .tree):
            let view = CollectionsCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        case (.collections, .list):
            return collectionsListWidgetProviderAssembly
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
            return setListWidgetProviderAssembly
        case .compactList:
            guard objectDetails.editorViewType == .set else { return nil }
            let view = SetCompactListWidgetSubmoduleView(data: widgetData)
            return HomeWidgeMigrationProviderAssembly(view: view.eraseToAnyView(), componentId: widgetInfo.id)
        }
    }
}
