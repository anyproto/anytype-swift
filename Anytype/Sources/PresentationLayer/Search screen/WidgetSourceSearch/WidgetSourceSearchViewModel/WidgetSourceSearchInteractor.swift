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
    func anytypeLibrarySearch(text: String) -> [WidgetAnytypeLibrarySource]
}

@MainActor
final class WidgetSourceSearchInteractor: WidgetSourceSearchInteractorProtocol {
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private let spaceId: String
    private let widgetObjectId: String
    private let anytypeLibrary = AnytypeWidgetId.availableWidgets.map { $0.librarySource }
    
    private var widgetTypeIds: [String]?
    
    init(spaceId: String, widgetObjectId: String) {
        self.spaceId = spaceId
        self.widgetObjectId = widgetObjectId
    }
    
    // MARK: - WidgetSourceSearchInteractorProtocol
    
    func objectsSearch(text: String) async throws -> [ObjectDetails] {
        try await searchService.search(text: text, spaceId: spaceId)
    }
    
    func objectsTypesSearch(text: String) async throws -> [ObjectDetails] {
        if widgetTypeIds.isNil {
            let widgetObject = documentsProvider.document(objectId: widgetObjectId, spaceId: spaceId, mode: .preview)
            try await widgetObject.open()
            let sourceIds = widgetObject.children
                .filter(\.isWidget)
                .compactMap { widgetObject.targetObjectIdByLinkFor(widgetBlockId: $0.id) }
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
    
    func anytypeLibrarySearch(text: String) -> [WidgetAnytypeLibrarySource] {
        guard text.isNotEmpty else { return anytypeLibrary }
        return anytypeLibrary.filter { $0.name.range(of: text, options: .caseInsensitive) != nil }
    }
}

private extension AnytypeWidgetId {
    var librarySource: WidgetAnytypeLibrarySource {
        switch self {
        case .favorite:
            return WidgetAnytypeLibrarySource(
                type: .favorite,
                name: Loc.favorite,
                description: nil,
                icon: .asset(.SystemWidgets.favorites)
            )
        case .sets:
            return WidgetAnytypeLibrarySource(
                type: .sets,
                name: Loc.sets,
                description: nil,
                icon: .object(.emoji(Emoji("📚")!))
            )
        case .collections:
            return WidgetAnytypeLibrarySource(
                type: .collections,
                name: Loc.collections,
                description: nil,
                icon: .object(.emoji(Emoji("📂")!))
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
        case .pages:
            return WidgetAnytypeLibrarySource(
                type: .pages,
                name: Loc.pages,
                description: nil,
                icon: .object(.emoji(Emoji("📄")!))
            )
        case .lists:
            return WidgetAnytypeLibrarySource(
                type: .lists,
                name: Loc.lists,
                description: nil,
                icon: .object(.emoji(Emoji("📦")!))
            )
        case .media:
            return WidgetAnytypeLibrarySource(
                type: .media,
                name: Loc.media,
                description: nil,
                icon: .object(.emoji(Emoji("🎞️")!))
            )
        case .bookmarks:
            return WidgetAnytypeLibrarySource(
                type: .bookmarks,
                name: Loc.bookmarks,
                description: nil,
                icon: .object(.emoji(Emoji("🌎")!))
            )
        case .files:
            return WidgetAnytypeLibrarySource(
                type: .files,
                name: Loc.files,
                description: nil,
                icon: .object(.emoji(Emoji("📁")!))
            )
        }
    }
}
