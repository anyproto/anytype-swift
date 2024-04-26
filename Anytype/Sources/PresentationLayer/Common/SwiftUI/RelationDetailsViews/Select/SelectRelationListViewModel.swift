import Combine
import Foundation
import Services
import SwiftUI

@MainActor
final class SelectRelationListViewModel: ObservableObject {
    
    @Published var selectedOptionsIds: [String] = []
    @Published var options: [SelectRelationOption] = []
    @Published var isEmpty = false
    @Published var searchText = ""
        
    let style: SelectRelationListStyle
    let configuration: RelationModuleConfiguration
    
    private let relationSelectedOptionsModel: RelationSelectedOptionsModelProtocol
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
    private weak var output: SelectRelationListModuleOutput?
    
    init(
        data: SelectRelationListData,
        output: SelectRelationListModuleOutput?
    ) {
        self.style = data.style
        self.configuration = data.configuration
        self.output = output
        self.relationSelectedOptionsModel = data.relationSelectedOptionsModel
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
            self?.updateListOnCreate(with: option.id)
        })
    }
    
    func onOptionDuplicate(_ option: SelectRelationOption) {
        onCreate(with: option.text, color: option.color)
    }
    
    func onOptionEdit(_ option: SelectRelationOption) {
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
    
    func onOptionDelete(_ option: SelectRelationOption) {
        output?.onDeleteTap { [weak self] isSuccess in
            guard let self else { return }
            if isSuccess {
                removeRelationOption(option)
            } else {
                options = options
            }            
        }
    }
    
    func optionSelected(_ optionId: String) {
        Task {
            try await relationSelectedOptionsModel.optionSelected(optionId)
            closeIfNeeded()
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
        ).map { SelectRelationOption(relation: $0) }
        
        switch configuration.selectionMode {
        case .single:
            options = rawOptions
        case .multi:
            options = rawOptions.reordered(
                by: selectedOptionsIds
            ) { $0.id }
        }
        
        if !configuration.isEditable {
            options = options.filter { selectedOptionsIds.contains($0.id) }
        }
        
        setEmptyIfNeeded()
    }
    
    private func updateListOnCreate(with optionId: String) {
        Task {
            searchText = ""
            try await relationSelectedOptionsModel.optionSelected(optionId)
            try await searchTextChangedAsync()
        }
    }
    
    private func removeRelationOption(_ option: SelectRelationOption) {
        Task {
            if let index = options.firstIndex(of: option) {
                options.remove(at: index)
            }
            try await relationSelectedOptionsModel.removeRelationOption(option.id)
            setEmptyIfNeeded()
        }
    }
    
    private func setEmptyIfNeeded() {
        isEmpty = options.isEmpty && searchText.isEmpty
    }
    
    private func closeIfNeeded() {
        if configuration.selectionMode == .single {
            output?.onClose()
        }
    }
}
