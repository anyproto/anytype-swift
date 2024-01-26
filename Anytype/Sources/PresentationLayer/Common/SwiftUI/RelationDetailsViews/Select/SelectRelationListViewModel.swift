import Combine
import Foundation
import Services
import SwiftUI

@MainActor
final class SelectRelationListViewModel: ObservableObject {
    
    @Published var selectedOption: SelectRelationOption?
    @Published var options: [SelectRelationOption] = []
    @Published var isEmpty = false
    
    private var searchText = ""
        
    let configuration: RelationModuleConfiguration
    
    private let relationsService: RelationsServiceProtocol
    private let searchService: SearchServiceProtocol
    
    private weak var output: SelectRelationListModuleOutput?
    
    init(
        configuration: RelationModuleConfiguration,
        selectedOption: SelectRelationOption?,
        output: SelectRelationListModuleOutput?,
        relationsService: RelationsServiceProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.configuration = configuration
        self.selectedOption = selectedOption
        self.output = output
        self.relationsService = relationsService
        self.searchService = searchService
    }

    func onClear() {
        Task {
            selectedOption = nil
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: nil)
            logChanges()
        }
    }
    
    func onCreate(with title: String?, color: Color? = nil) {
        output?.onCreateTap(text: title, color: color, completion: { [weak self] optionId in
            self?.optionSelected(optionId, dismiss: false)
        })
    }
    
    func onOptionEdit(_ option: SelectRelationOption) {
        output?.onEditTap(option: option, completion: { [weak self] in
            guard let self else { return }
            searchTextChanged(searchText)
        })
    }
    
    func onOptionDuplicate(_ option: SelectRelationOption) {
        output?.onCreateTap(text: option.text, color: option.color, completion: { [weak self] optionId in
            self?.optionSelected(optionId, dismiss: false)
        })
    }
    
    func onOptionDelete(_ option: SelectRelationOption) {
        output?.onDeleteTap { [weak self] isSuccess in
            guard isSuccess else { return }
            self?.removeRelationOprion(id: option.id)
        }
    }
    
    func optionSelected(_ optionId: String, dismiss: Bool = true) {
        Task {
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: optionId.protobufValue)
            
            let newOption = try await searchService.searchRelationOptions(
                optionIds: [optionId],
                spaceId: configuration.spaceId
            ).first.map { SelectRelationOption(relation: $0) }
            
            selectedOption = newOption
            logChanges()
            
            if dismiss {
                output?.onClose()
            } else {
                searchTextChanged(searchText)
            }
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
            searchText = text
        }
    }
    
    private func removeRelationOprion(id: String) {
        Task {
            try await relationsService.removeRelationOptions(ids: [id])
            searchTextChanged(searchText)
            if selectedOption?.id == id {
                onClear()
            }
        }
    }
    
    private func logChanges() {
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedOption.isNil, type: configuration.analyticsType)
    }
}
