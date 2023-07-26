import Foundation
import Services

final class StatusSearchInteractor {
    
    private let spaceId: String
    private let relationKey: String
    private let selectedStatusesIds: [String]
    private let isPreselectModeAvailable: Bool
    private let searchService: SearchServiceProtocol
    
    init(
        spaceId: String,
        relationKey: String,
        selectedStatusesIds: [String],
        isPreselectModeAvailable: Bool,
        searchService: SearchServiceProtocol
    ) {
        self.spaceId = spaceId
        self.relationKey = relationKey
        self.selectedStatusesIds = selectedStatusesIds
        self.isPreselectModeAvailable = isPreselectModeAvailable
        self.searchService = searchService
    }
    
}

extension StatusSearchInteractor {
    
    func search(text: String) async throws -> [Relation.Status.Option] {
        try await searchService.searchRelationOptions(
            text: text,
            relationKey: relationKey,
            excludedObjectIds: selectedStatusesIds,
            spaceId: spaceId
        ).map { Relation.Status.Option(option: $0) }
    }
    
    func isCreateButtonAvailable(searchText: String, statuses: [Relation.Status.Option]) -> Bool {
        searchText.isNotEmpty && statuses.isEmpty
    }
    
}
