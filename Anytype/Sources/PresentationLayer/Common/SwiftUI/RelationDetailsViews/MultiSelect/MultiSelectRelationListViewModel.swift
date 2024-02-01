import Combine
import Foundation
import Services
import SwiftUI

@MainActor
final class MultiSelectRelationListViewModel: ObservableObject {
    
    @Published var selectedOptionsIds: [String] = []
    @Published var options: [MultiSelectRelationOption] = []
    @Published var isEmpty = false
    @Published var searchText = ""
        
    let configuration: RelationModuleConfiguration
    
    private let relationSelectedOptionsModel: RelationSelectedOptionsModelProtocol
    private let searchService: SearchServiceProtocol
    
    private weak var output: MultiSelectRelationListModuleOutput?
    
    init(
        configuration: RelationModuleConfiguration,
        relationSelectedOptionsModel: RelationSelectedOptionsModelProtocol,
        searchService: SearchServiceProtocol,
        output: MultiSelectRelationListModuleOutput?
    ) {
        self.configuration = configuration
        self.relationSelectedOptionsModel = relationSelectedOptionsModel
        self.output = output
        self.searchService = searchService
        self.relationSelectedOptionsModel.selectedOptionsIdsPublisher.assign(to: &$selectedOptionsIds)
    }
    
    func onAppear() {
        searchTextChanged()
    }

    func onClear() {
        Task {
            try await relationSelectedOptionsModel.onClear()
        }
    }
    
    func onCreate(with title: String?, color: Color? = nil) {
        output?.onCreateTap(text: title, color: color, completion: { [weak self] option in
            self?.updateListOnCreate(with: option)
        })
    }
    
    func onOptionDuplicate(_ option: MultiSelectRelationOption) {
        onCreate(with: option.text, color: option.textColor)
    }
    
    func onOptionEdit(_ option: MultiSelectRelationOption) {
        output?.onEditTap(option: option, completion: { [weak self] option in
            guard let self else { return }
            if let index = options.firstIndex(where: { $0.id == option.id }) {
                options[index] = option
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
                options = options
            }
        }
    }
    
    func optionSelected(_ option: MultiSelectRelationOption) {
        Task {
            try await relationSelectedOptionsModel.optionSelected(option.id)
        }
    }
    
    func searchTextChanged(_ text: String = "") {
        Task {
            try await searchTextChangedAsync(text)
        }
    }
    
    private func searchTextChangedAsync(_ text: String = "") async throws {
        let rawOptions = try await searchService.searchRelationOptions(
            text: text,
            relationKey: configuration.relationKey,
            excludedObjectIds: [],
            spaceId: configuration.spaceId
        ).map { MultiSelectRelationOption(relation: $0) }
        
        if configuration.isEditable {
            options = rawOptions.reordered(
                by: selectedOptionsIds
            ) { $0.id }
        } else {
            options = options.filter { selectedOptionsIds.contains($0.id) }
        }
        
        setEmptyIfNeeded()
    }
    
    private func updateListOnCreate(with option: MultiSelectRelationOption) {
        Task {
            searchText = ""
            try await relationSelectedOptionsModel.optionSelected(option.id)
            try await searchTextChangedAsync()
        }
    }
    
    private func setEmptyIfNeeded() {
        isEmpty = options.isEmpty && searchText.isEmpty
    }
    
    private func removeRelationOption(_ option: MultiSelectRelationOption) {
        Task {
            if let index = options.firstIndex(of: option) {
                options.remove(at: index)
            }
            try await relationSelectedOptionsModel.removeRelationOption(option.id)
            setEmptyIfNeeded()
        }
    }
}
