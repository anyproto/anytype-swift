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
}

final class WidgetSourceSearchInteractor: WidgetSourceSearchInteractorProtocol {
    
    private let searchService: SearchServiceProtocol
    private let anytypeLibrary = AnytypeWidgetId.allCases.map { $0.librarySource }
    
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    
    // MARK: - WidgetSourceSearchInteractorProtocol
    
    func objectSearch(text: String) async throws -> [ObjectDetails] {
        try await searchService.search(text: text)
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
                icon: .object(.emoji(Emoji("⭐️") ?? .default))
            )
        case .sets:
            return WidgetAnytypeLibrarySource(
                type: .sets,
                name: Loc.sets,
                description: nil,
                icon: .object(.emoji(Emoji("📚") ?? .default))
            )
        case .collections:
            return WidgetAnytypeLibrarySource(
                type: .collections,
                name: Loc.collections,
                description: nil,
                icon: .object(.emoji(Emoji("📂") ?? .default))
            )
        case .recent:
            return WidgetAnytypeLibrarySource(
                type: .recent,
                name: Loc.Widgets.Library.RecentlyEdited.name,
                description: nil,
                icon: .object(.emoji(Emoji("📝") ?? .default))
            )
        case .recentOpen:
            return WidgetAnytypeLibrarySource(
                type: .recentOpen,
                name: Loc.Widgets.Library.RecentlyOpened.name,
                description: Loc.Widgets.Library.RecentlyOpened.description,
                icon: .object(.emoji(Emoji("📅") ?? .default))
            )
        }
    }
}
