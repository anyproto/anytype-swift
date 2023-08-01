import Foundation
import Services
import AnytypeCore

struct WidgetAnytypeLibrarySource: Hashable {
    let type: AnytypeWidgetId
    let name: String
    let icon: Icon
}

protocol WidgetSourceSearchInteractorProtocol: AnyObject {
    func objectSearch(text: String) async throws -> [ObjectDetails]
    func anytypeLibrarySearch(text: String) -> [WidgetAnytypeLibrarySource]
}

final class WidgetSourceSearchInteractor: WidgetSourceSearchInteractorProtocol {
    
    private let searchService: SearchServiceProtocol
    private let anytypeLibrary = [
        WidgetAnytypeLibrarySource(type: .favorite, name: Loc.favorite, icon: .object(.emoji(Emoji("⭐️") ?? .default))),
        WidgetAnytypeLibrarySource(type: .sets, name: Loc.sets, icon: .object(.emoji(Emoji("📚") ?? .default))),
        WidgetAnytypeLibrarySource(type: .collections, name: Loc.collections, icon: .object(.emoji(Emoji("📂") ?? .default))),
        WidgetAnytypeLibrarySource(type: .recent, name: Loc.recent, icon: .object(.emoji(Emoji("📅") ?? .default)))
    ]
    
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    
    // MARK: - WidgetSourceSearchInteractorProtocol
    
    func objectSearch(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjects(
            text: text,
            excludedObjectIds: [],
            limitedTypeIds: []
        )
    }
    
    func anytypeLibrarySearch(text: String) -> [WidgetAnytypeLibrarySource] {
        guard text.isNotEmpty else { return anytypeLibrary }
        return anytypeLibrary.filter { $0.name.range(of: text, options: .caseInsensitive) != nil }
    }
}
