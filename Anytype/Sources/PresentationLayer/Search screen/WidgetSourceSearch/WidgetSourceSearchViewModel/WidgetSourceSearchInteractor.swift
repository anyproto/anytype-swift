import Foundation
import Services
import AnytypeCore

struct WidgetAnytypeLibrarySource: Hashable {
    let type: AnytypeWidgetId
    let name: String
    let description: String?
    let icon: Icon
}

protocol WidgetSourceSearchInteractorProtocol: AnyObject {
    func objectSearch(text: String) async throws -> [ObjectDetails]
    func anytypeLibrarySearch(text: String) -> [WidgetAnytypeLibrarySource]
    func createNewObject(name: String) async throws -> ObjectDetails
}

final class WidgetSourceSearchInteractor: WidgetSourceSearchInteractorProtocol {
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    private let spaceId: String
    private let anytypeLibrary = FeatureFlags.discussions
                                    ? AnytypeWidgetId.allCases.map { $0.librarySource }
                                    : AnytypeWidgetId.allCases.filter { $0 != .chat }.map { $0.librarySource }
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    // MARK: - WidgetSourceSearchInteractorProtocol
    
    func objectSearch(text: String) async throws -> [ObjectDetails] {
        try await searchService.search(text: text, spaceId: spaceId)
    }
    
    func anytypeLibrarySearch(text: String) -> [WidgetAnytypeLibrarySource] {
        guard text.isNotEmpty else { return anytypeLibrary }
        return anytypeLibrary.filter { $0.name.range(of: text, options: .caseInsensitive) != nil }
    }
    
    func createNewObject(name: String) async throws -> ObjectDetails {
        let details = try await defaultObjectService.createDefaultObject(
            name: name,
            shouldDeleteEmptyObject: false,
            spaceId: spaceId
        )
        AnytypeAnalytics.instance().logCreateObject(
            objectType: details.analyticsType,
            spaceId: details.spaceId,
            route: .search
        )
        return details
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
                icon: .object(.emoji(Emoji("⭐️")!))
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
                icon: .object(.emoji(Emoji("📝")!))
            )
        case .recentOpen:
            return WidgetAnytypeLibrarySource(
                type: .recentOpen,
                name: Loc.Widgets.Library.RecentlyOpened.name,
                description: Loc.Widgets.Library.RecentlyOpened.description,
                icon: .object(.emoji(Emoji("📅")!))
            )
        case .chat:
            return WidgetAnytypeLibrarySource(
                type: .chat,
                name: Loc.Widgets.Library.Chat.name,
                description: nil,
                icon: .object(.emoji(Emoji("💬")!))
            )
        }
    }
}
