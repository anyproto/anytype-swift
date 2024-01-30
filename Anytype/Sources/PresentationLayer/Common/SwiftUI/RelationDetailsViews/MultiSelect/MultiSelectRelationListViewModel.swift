import Combine
import Foundation
import Services
import SwiftUI

@MainActor
final class MultiSelectRelationListViewModel: ObservableObject {
    
    @Published var selectedOptions: [String]
    @Published var visibleOptions: [MultiSelectRelationOption] = []
    @Published var isEmpty = false
    
    private var options: [MultiSelectRelationOption] = []
    private var searchText = ""
        
    let configuration: RelationModuleConfiguration
    
    private let relationsService: RelationsServiceProtocol
    private let searchService: SearchServiceProtocol
    
    private weak var output: MultiSelectRelationListModuleOutput?
    
    init(
        configuration: RelationModuleConfiguration,
        selectedOptions: [String],
        output: MultiSelectRelationListModuleOutput?,
        relationsService: RelationsServiceProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.configuration = configuration
        self.selectedOptions = selectedOptions
        self.output = output
        self.relationsService = relationsService
        self.searchService = searchService
    }
    
    func onAppear() {
        loadOptions()
    }

    func onClear() {
        Task {
            selectedOptions = []
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: nil)
            logChanges()
        }
    }
    
    func onCreate(with title: String?, color: Color? = nil) {
        output?.onCreateTap(text: title, color: color, completion: { [weak self] option in
            guard let self else { return }
            options.append(option)
            optionSelected(option)
            searchTextChanged(searchText)
        })
    }
    
    func onOptionDuplicate(_ option: MultiSelectRelationOption) {
        onCreate(with: option.text, color: option.textColor)
    }
    
    func onOptionEdit(_ option: MultiSelectRelationOption) {
        output?.onEditTap(option: option, completion: { [weak self] option in
            guard let self else { return }
            if let index = options.firstIndex(of: option) {
                options[index] = option
                searchTextChanged(searchText)
            }
        })
    }
    
    func onOptionDelete(with indexSet: IndexSet) {
        indexSet.forEach { deleteIndex in
            guard deleteIndex < options.count else { return }
            let optionToDelete = options[deleteIndex]
            onOptionDelete(optionToDelete)
        }
    }
    
    func onOptionDelete(_ option: MultiSelectRelationOption) {
        output?.onDeleteTap { [weak self] isSuccess in
            guard let self else { return }
            if isSuccess {
                removeRelationOption(option)
            } else {
                visibleOptions = visibleOptions
            }
        }
    }
    
    func optionSelected(_ option: MultiSelectRelationOption) {
        var tempOptions = selectedOptions
        if let index = tempOptions.firstIndex(of: option.id) {
            tempOptions.remove(at: index)
        } else {
            tempOptions.append(option.id)
        }
        
        Task {
            try await relationsService.updateRelation(
                relationKey: configuration.relationKey,
                value: tempOptions.protobufValue
            )
            selectedOptions = tempOptions
            logChanges()
        }
    }
    
    func searchTextChanged(_ text: String) {
        searchText = text
        
        guard text.isNotEmpty else {
            visibleOptions = options
            return
        }
        
        visibleOptions = options.filter {
            $0.text.range(of: text, options: .caseInsensitive) != nil
        }
    }
    
    private func loadOptions() {
        Task {
            let rawOptions = try await searchService.searchRelationOptions(
                text: "",
                relationKey: configuration.relationKey,
                excludedObjectIds: [],
                spaceId: configuration.spaceId
            ).map { MultiSelectRelationOption(relation: $0) }
            
            if configuration.isEditable {
                options = rawOptions.reordered(
                    by: selectedOptions
                ) { $0.id }
            } else {
                options = options.filter { [weak self] in
                    self?.selectedOptions.contains($0.id) ?? false
                }
            }
            
            visibleOptions = options
            isEmpty = options.isEmpty
        }
    }
    
    private func removeRelationOption(_ option: MultiSelectRelationOption) {
        Task {
            try await relationsService.removeRelationOptions(ids: [option.id])
            if let index = options.firstIndex(of: option) {
                options.remove(at: index)
            }
            
            if let index = selectedOptions.firstIndex(of: option.id) {
                var tempOptions = selectedOptions
                tempOptions.remove(at: index)
                try await relationsService.updateRelation(
                    relationKey: configuration.relationKey,
                    value: tempOptions.protobufValue
                )
                selectedOptions = tempOptions
            }
            searchTextChanged(searchText)
        }
    }
    
    private func logChanges() {
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedOptions.isEmpty, type: configuration.analyticsType)
    }
}
