import Foundation
import Services
import AnytypeCore

struct WidgetAnytypeLibrarySource: Hashable {
    let type: AnytypeWidgetId
    let name: String
    let description: String?
    let icon: Icon
}

@MainActor
protocol WidgetSourceSearchInteractorProtocol: AnyObject {
    func objectsTypesSearch(text: String) async throws -> [ObjectDetails]
    func objectsSearch(text: String) async throws -> [ObjectDetails]
    func anytypeLibrarySearch(text: String) async throws -> [WidgetAnytypeLibrarySource]
}

@MainActor
final class WidgetSourceSearchInteractor: WidgetSourceSearchInteractorProtocol {
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    private let openedDocumentsProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    
    private let spaceId: String
    private let widgetObjectId: String
    private let anytypeLibrary = AnytypeWidgetId.availableWidgets.map { $0.librarySource }
    private let widgetObject: any BaseDocumentProtocol
    private let spaceView: SpaceView?
    
    private var widgetTypeIds: [String]?
    
    init(spaceId: String, widgetObjectId: String) {
        self.spaceId = spaceId
        self.widgetObjectId = widgetObjectId
        self.widgetObject = openedDocumentsProvider.document(objectId: widgetObjectId, spaceId: spaceId, mode: .preview)
        self.spaceView = workspaceStorage.spaceView(spaceId: spaceId)
    }
    
    // MARK: - WidgetSourceSearchInteractorProtocol
    
    func objectsSearch(text: String) async throws -> [ObjectDetails] {
        try await searchService.search(text: text, spaceId: spaceId)
    }
    
    func objectsTypesSearch(text: String) async throws -> [ObjectDetails] {
        if widgetTypeIds.isNil {
            let sourceIds = try await sourceIds()
            let objectTypes = objectTypeProvider.objectTypes(spaceId: spaceId)
            let excludedExistedIds = objectTypes
                .filter { sourceIds.contains($0.id) }
                .map { $0.id }
            let excludedTypeIds = objectTypes
                .filter { $0.uniqueKey == ObjectTypeUniqueKey.template || $0.uniqueKey == ObjectTypeUniqueKey.objectType }
                .map { $0.id }
            widgetTypeIds = excludedExistedIds + excludedTypeIds
        }
        
        return try await searchService.searchObjectsWithLayouts(
            text: text,
            layouts: [.objectType],
            excludedIds: widgetTypeIds ?? [],
            spaceId: spaceId
        )
    }
    
    func anytypeLibrarySearch(text: String) async throws -> [WidgetAnytypeLibrarySource] {
        let sourceIds = try await sourceIds()
        var anytypeLibrary = anytypeLibrary.filter { !sourceIds.contains($0.type.rawValue) }
        
        if spaceView?.canAddChatWidget == false {
            anytypeLibrary.removeAll { $0.type == .chat }
        }
        
        guard text.isNotEmpty else { return anytypeLibrary }
        return anytypeLibrary.filter { $0.name.range(of: text, options: .caseInsensitive) != nil }
    }
    
    private func sourceIds() async throws -> [String] {
        try await widgetObject.open()
        return widgetObject.children
            .filter(\.isWidget)
            .compactMap { widgetObject.targetObjectIdByLinkFor(widgetBlockId: $0.id) }
    }
}

private extension AnytypeWidgetId {
    var librarySource: WidgetAnytypeLibrarySource {
        switch self {
        case .allObjects:
            return WidgetAnytypeLibrarySource(
                type: .allObjects,
                name: Loc.allObjects,
                description: nil,
                icon: .asset(.SystemWidgets.allObjects)
            )
        case .pinned:
            return WidgetAnytypeLibrarySource(
                type: .pinned,
                name: Loc.pinned,
                description: nil,
                icon: .asset(.SystemWidgets.favorites)
            )
        case .recent:
            return WidgetAnytypeLibrarySource(
                type: .recent,
                name: Loc.Widgets.Library.RecentlyEdited.name,
                description: nil,
                icon: .asset(.SystemWidgets.recentlyEdited)
            )
        case .recentOpen:
            return WidgetAnytypeLibrarySource(
                type: .recentOpen,
                name: Loc.Widgets.Library.RecentlyOpened.name,
                description: Loc.Widgets.Library.RecentlyOpened.description,
                icon: .asset(.SystemWidgets.recentlyOpened)
            )
        case .bin:
            return WidgetAnytypeLibrarySource(
                type: .bin,
                name: Loc.bin,
                description: nil,
                icon: .asset(.SystemWidgets.bin)
            )
        case .chat:
            return WidgetAnytypeLibrarySource(
                type: .chat,
                name: Loc.chat,
                description: nil,
                icon: .asset(.SystemWidgets.chat)
            )
        }
    }
}
