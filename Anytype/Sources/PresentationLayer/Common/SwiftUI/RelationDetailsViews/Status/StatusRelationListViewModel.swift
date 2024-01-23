import Combine
import Foundation
import Services

@MainActor
final class StatusRelationListViewModel: ObservableObject {
    
    @Published var selectedStatus: Relation.Status.Option?
    @Published var statuses: [Relation.Status.Option] = []
    @Published var isEmpty = false
    @Published var dismiss = false
        
    let configuration: RelationModuleConfiguration
    
    private let relationsService: RelationsServiceProtocol
    private let searchService: SearchServiceProtocol
    
    init(
        configuration: RelationModuleConfiguration,
        selectedStatus: Relation.Status.Option?,
        relationsService: RelationsServiceProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.configuration = configuration
        self.selectedStatus = selectedStatus
        self.relationsService = relationsService
        self.searchService = searchService
    }

    func clear() {
        Task {
            selectedStatus = nil
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: nil)
            logChanges()
        }
    }
    
    func create(with title: String?) {
        Task {
            let statusId = try await relationsService.addRelationOption(
                spaceId: configuration.spaceId,
                relationKey: configuration.relationKey,
                optionText: title ?? ""
            )
            
            guard let statusId else { return }
            
            statusSelected(statusId)
        }
        
    }
    
    func statusSelected(_ statusId: String) {
        Task {
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: statusId.protobufValue)
            
            let newStatus = try await searchService.searchRelationOptions(
                optionIds: [statusId],
                spaceId: configuration.spaceId
            ).first.map { Relation.Status.Option(option: $0) }
            
            selectedStatus = newStatus
            logChanges()
            dismiss = true
        }
    }
    
    func searchTextChanged(_ text: String = "") {
        Task {
            statuses = try await searchService.searchRelationOptions(
                text: text,
                relationKey: configuration.relationKey,
                excludedObjectIds: [],
                spaceId: configuration.spaceId
            ).map { Relation.Status.Option(option: $0) }
            
            isEmpty = statuses.isEmpty && text.isEmpty
        }
    }
    
    func logChanges() {
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedStatus.isNil, type: configuration.analyticsType)
    }
}
