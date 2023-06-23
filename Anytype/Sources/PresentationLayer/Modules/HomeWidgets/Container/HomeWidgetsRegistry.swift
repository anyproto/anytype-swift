import Foundation
import Services
import AnytypeCore

protocol HomeWidgetsRegistryProtocol {
    func providers(blocks: [BlockInformation], widgetObject: BaseDocumentProtocol) -> [HomeWidgetSubmoduleModel]
}

final class HomeWidgetsRegistry: HomeWidgetsRegistryProtocol {

    private struct ProviderCache {
        let widgetBlockId: String
        let widgetObjectId: String
        let provider: HomeSubmoduleProviderProtocol
        let source: HomeWidgetProviderAssemblyProtocol
    }
    
    private enum Constants {
        static let binWidgetId = "BinWidgetId"
    }
    
    // MARK: - DI
    // MARK: - Tree
    private let objectTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let favoriteTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let recentTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    // Delete with compactListWidget toggle
    private let setsTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let collectionsTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    // MARK: - List
    private let setListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let favoriteListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let recentListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let setsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let collectionsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    // MARK: - CompactList
    private let setCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let favoriteCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let recentCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let setsCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let collectionsCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    
    private let linkWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let binLinkWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private var providersCache: [ProviderCache] = []
    
    init(
        objectTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        favoriteTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        recentTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setsTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        collectionsTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        favoriteListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        recentListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        collectionsListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        favoriteCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        recentCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        setsCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        collectionsCompactListWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        linkWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        binLinkWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) {
        self.objectTreeWidgetProviderAssembly = objectTreeWidgetProviderAssembly
        self.favoriteTreeWidgetProviderAssembly = favoriteTreeWidgetProviderAssembly
        self.recentTreeWidgetProviderAssembly = recentTreeWidgetProviderAssembly
        self.setsTreeWidgetProviderAssembly = setsTreeWidgetProviderAssembly
        self.collectionsTreeWidgetProviderAssembly = collectionsTreeWidgetProviderAssembly
        self.setListWidgetProviderAssembly = setListWidgetProviderAssembly
        self.favoriteListWidgetProviderAssembly = favoriteListWidgetProviderAssembly
        self.recentListWidgetProviderAssembly = recentListWidgetProviderAssembly
        self.setsListWidgetProviderAssembly = setsListWidgetProviderAssembly
        self.collectionsListWidgetProviderAssembly = collectionsListWidgetProviderAssembly
        self.setCompactListWidgetProviderAssembly = setCompactListWidgetProviderAssembly
        self.favoriteCompactListWidgetProviderAssembly = favoriteCompactListWidgetProviderAssembly
        self.recentCompactListWidgetProviderAssembly = recentCompactListWidgetProviderAssembly
        self.setsCompactListWidgetProviderAssembly = setsCompactListWidgetProviderAssembly
        self.collectionsCompactListWidgetProviderAssembly = collectionsCompactListWidgetProviderAssembly
        self.linkWidgetProviderAssembly = linkWidgetProviderAssembly
        self.binLinkWidgetProviderAssembly = binLinkWidgetProviderAssembly
        self.stateManager = stateManager
    }
    
    // MARK: - HomeWidgetsRegistryProtocol
    
    func providers(
        blocks: [BlockInformation],
        widgetObject: BaseDocumentProtocol
    ) -> [HomeWidgetSubmoduleModel] {
        
        var newProvidersCache: [ProviderCache] = blocks.compactMap { block in
            guard let widgetInfo = widgetObject.widgetInfo(block: block),
                  let provider = providerForInfo(widgetInfo) else { return nil }
            
            return createProviderCache(
                source: provider,
                widgetBlockId: block.id,
                widgetObject: widgetObject
            )
        }
        
        newProvidersCache.append(
            createProviderCache(
                source: binLinkWidgetProviderAssembly,
                widgetBlockId: Constants.binWidgetId,
                widgetObject: widgetObject
            )
        )
        
        providersCache = newProvidersCache
        return providersCache.map { HomeWidgetSubmoduleModel(blockId: $0.widgetBlockId, provider: $0.provider) }
    }
    
    // MARK: - Private
    
    private func createProviderCache(
        source: HomeWidgetProviderAssemblyProtocol,
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol
    ) -> ProviderCache {
        let cache = providersCache.first {
            $0.source === source
            && $0.widgetBlockId == widgetBlockId
            && $0.widgetObjectId == widgetObject.objectId
        }
        
        if let cache {
            return cache
        }
        
        let provider = source.make(widgetBlockId: widgetBlockId, widgetObject: widgetObject, stateManager: stateManager)
        
        let newCache = ProviderCache(
            widgetBlockId: widgetBlockId,
            widgetObjectId: widgetObject.objectId,
            provider: provider,
            source: source
        )
        
        return newCache
    }
    
    private func providerForInfo(_ widgetInfo: BlockWidgetInfo) -> HomeWidgetProviderAssemblyProtocol? {
        switch widgetInfo.source {
        case .object(let objectDetails):
            return providerForObject(objectDetails, widget: widgetInfo.block)
        case .library(let anytypeWidgetId):
            return providerForAnytypeWidgetId(anytypeWidgetId, widget: widgetInfo.block)
        }
    }
    
    private func providerForAnytypeWidgetId(_ anytypeWidgetId: AnytypeWidgetId, widget: BlockWidget) -> HomeWidgetProviderAssemblyProtocol? {
        switch (anytypeWidgetId, widget.layout) {
        case (.favorite, .tree):
            return favoriteTreeWidgetProviderAssembly
        case (.favorite, .list):
            return favoriteListWidgetProviderAssembly
        case (.favorite, .compactList):
            return favoriteCompactListWidgetProviderAssembly
        case (.recent, .tree):
            return recentTreeWidgetProviderAssembly
        case (.recent, .list):
            return recentListWidgetProviderAssembly
        case (.recent, .compactList):
            return recentCompactListWidgetProviderAssembly
        case (.sets, .tree):
            if FeatureFlags.compactListWidget {
                return setsCompactListWidgetProviderAssembly
            } else {
                return setsTreeWidgetProviderAssembly
            }
        case (.sets, .list):
            return setsListWidgetProviderAssembly
        case (.sets, .compactList):
            return setsCompactListWidgetProviderAssembly
        case (.collections, .tree):
            if FeatureFlags.compactListWidget {
                return collectionsCompactListWidgetProviderAssembly
            } else {
                return collectionsTreeWidgetProviderAssembly
            }
        case (.collections, .list):
            return collectionsListWidgetProviderAssembly
        case (.collections, .compactList):
            return collectionsCompactListWidgetProviderAssembly
        case (_, .link):
            return nil
        }
    }
    
    private func providerForObject(_ objectDetails: ObjectDetails, widget: BlockWidget) -> HomeWidgetProviderAssemblyProtocol? {
        
        guard objectDetails.isVisibleForEdit else { return nil }
        
        switch widget.layout {
        case .link:
            return linkWidgetProviderAssembly
        case .tree:
            guard objectDetails.editorViewType == .page else { return nil }
            return objectTreeWidgetProviderAssembly
        case .list:
            guard objectDetails.editorViewType == .set else { return nil }
            return setListWidgetProviderAssembly
        case .compactList:
            guard objectDetails.editorViewType == .set else { return nil }
            return setCompactListWidgetProviderAssembly
        }
    }
}
