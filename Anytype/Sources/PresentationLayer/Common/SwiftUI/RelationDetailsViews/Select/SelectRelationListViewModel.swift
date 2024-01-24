import Combine
import Foundation
import Services

@MainActor
final class SelectRelationListViewModel: ObservableObject {
    
    @Published var selectedOption: SelectRelationOption?
    @Published var options: [SelectRelationOption] = []
    @Published var isEmpty = false
    @Published var dismiss = false
        
    let configuration: RelationModuleConfiguration
    
    private let relationsService: RelationsServiceProtocol
    private let searchService: SearchServiceProtocol
    
    init(
        configuration: RelationModuleConfiguration,
        selectedOption: SelectRelationOption?,
        relationsService: RelationsServiceProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.configuration = configuration
        self.selectedOption = selectedOption
        self.relationsService = relationsService
        self.searchService = searchService
    }

    func clear() {
        Task {
            selectedOption = nil
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: nil)
            logChanges()
        }
    }
    
    func create(with title: String?) {
        Task {
            let optionId = try await relationsService.addRelationOption(
                spaceId: configuration.spaceId,
                relationKey: configuration.relationKey,
                optionText: title ?? ""
            )
            
            guard let optionId else { return }
            
            optionSelected(optionId)
        }
        
    }
    
    func optionSelected(_ optionId: String) {
        Task {
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: optionId.protobufValue)
            
            let newOption = try await searchService.searchRelationOptions(
                optionIds: [optionId],
                spaceId: configuration.spaceId
            ).first.map { SelectRelationOption(relation: $0) }
            
            selectedOption = newOption
            logChanges()
            dismiss = true
        }
    }
    
    func searchTextChanged(_ text: String = "") {
        Task {
            let rawOptions = try await searchService.searchRelationOptions(
                text: text,
                relationKey: configuration.relationKey,
                excludedObjectIds: [],
                spaceId: configuration.spaceId
            ).map { SelectRelationOption(relation: $0) }
            
            if configuration.isEditable {
                options = rawOptions.reordered(
                    by: [ selectedOption?.id ?? "" ]
                ) { $0.id }
            } else {
                options = [selectedOption].compactMap { $0 }
            }
            
            isEmpty = options.isEmpty && text.isEmpty
        }
    }
    
    func logChanges() {
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedOption.isNil, type: configuration.analyticsType)
    }
}
