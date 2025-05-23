import Combine
import Foundation
import Services
import SwiftUI

@MainActor
final class SelectPropertyListViewModel: ObservableObject {
    
    @Published var selectedOptionsIds: [String] = []
    @Published var options: [SelectPropertyOption] = []
    @Published var isEmpty = false
    @Published var searchText = ""
        
    let style: SelectPropertyListStyle
    let configuration: PropertyModuleConfiguration
    
    private let relationSelectedOptionsModel: any PropertySelectedOptionsModelProtocol
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    private weak var output: (any SelectPropertyListModuleOutput)?
    
    init(
        data: SelectPropertyListData,
        output: (any SelectPropertyListModuleOutput)?
    ) {
        self.style = data.style
        self.configuration = data.configuration
        self.output = output
        self.relationSelectedOptionsModel = data.relationSelectedOptionsModel
        self.relationSelectedOptionsModel.selectedOptionsIdsPublisher.receiveOnMain().assign(to: &$selectedOptionsIds)
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
    
    func onOptionDuplicate(_ option: SelectPropertyOption) {
        onCreate(with: option.text, color: option.color)
    }
    
    func onOptionEdit(_ option: SelectPropertyOption) {
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
    
    func onOptionDelete(_ option: SelectPropertyOption) {
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
    
    func searchTextChanged() async {
        do {
            let rawOptions = try await searchService.searchRelationOptions(
                text: searchText,
                relationKey: configuration.relationKey,
                excludedObjectIds: [],
                spaceId: configuration.spaceId
            ).map { SelectPropertyOption(relation: $0) }
            
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
        } catch { }
    }
    
    private func updateListOnCreate(with optionId: String) {
        Task {
            searchText = ""
            try await relationSelectedOptionsModel.optionSelected(optionId)
            await searchTextChanged()
        }
    }
    
    private func removeRelationOption(_ option: SelectPropertyOption) {
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
