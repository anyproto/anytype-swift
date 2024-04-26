import Combine
import Foundation
import Services
import SwiftUI

struct ObjectRelationTypeItem {
    let name: String
    let isSelected: Bool
}

@MainActor
final class ObjectRelationListViewModel: ObservableObject {
    
    @Published var selectedOptionsIds: [String] = []
    @Published var options: [ObjectRelationOption] = []
    @Published var isEmpty = false
    @Published var searchText = ""
    
    let configuration: RelationModuleConfiguration
    
    private let interactor: ObjectRelationListInteractorProtocol
    private let relationSelectedOptionsModel: RelationSelectedOptionsModelProtocol
    
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    
    private weak var output: ObjectRelationListModuleOutput?
    
    init(data: ObjectRelationListData, output: ObjectRelationListModuleOutput?) {
        self.configuration = data.configuration
        self.output = output
        self.interactor = data.interactor
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
    
    func onObjectOpen(_ option: ObjectRelationOption) {
        output?.onObjectOpen(screenData: option.editorScreenData)
    }
    
    func onObjectDuplicate(_ option: ObjectRelationOption) {
        Task {
            let newOptionId =  try await objectActionsService.duplicate(objectId: option.id)
            try await relationSelectedOptionsModel.optionSelected(newOptionId)
            try await searchTextChangedAsync(searchText)
        }
    }
    
    func onOptionDelete(with indexSet: IndexSet) {
        indexSet.forEach { deleteIndex in
            guard deleteIndex < options.count else { return }
            let optionToDelete = options[deleteIndex]
            onOptionDelete(optionToDelete)
        }
    }
    
    func onOptionDelete(_ option: ObjectRelationOption) {
        output?.onDeleteTap { [weak self] isSuccess in
            guard let self else { return }
            if isSuccess {
                removeRelationOption(option)
            } else {
                options = options
            }
        }
    }
    
    func optionSelected(_ option: ObjectRelationOption) {
        if configuration.isEditable {
            Task {
                try await relationSelectedOptionsModel.optionSelected(option.id)
                closeIfNeeded()
            }
        } else {
            onObjectOpen(option)
        }
    }
    
    func objectRelationTypeItems() -> [ObjectRelationTypeItem]? {
        let typesNames = interactor.limitedObjectTypes.map { $0.name }
        
        guard typesNames.isNotEmpty else { return nil }
        
        var items = typesNames.enumerated().map { index, name in
            var separator = ","
            if typesNames.count - 1 == index {
                separator = ""
            }
            return ObjectRelationTypeItem(name: name + separator, isSelected: true)
            
        }
        let title = typesNames.count == 1 ? Loc.Relation.ObjectType.Header.title : Loc.Relation.ObjectTypes.Header.title
        items.insert(
            ObjectRelationTypeItem(
                name: title,
                isSelected: false
            ),
            at: 0
        )
        return items
    }
    
    func searchTextChanged(_ text: String = "") {
        Task {
            try await searchTextChangedAsync(text)
        }
    }
    
    private func searchTextChangedAsync(_ text: String = "") async throws {
        let selectedOptions = try await interactor.searchOptions(text: text, limitObjectIds: selectedOptionsIds)
        let rawOptions = try await interactor.searchOptions(text: text, excludeObjectIds: selectedOptionsIds)
        
        let selectedReorder = selectedOptions
            .reordered(
                by: selectedOptionsIds
            ) { $0.id }
        
        options = selectedReorder + rawOptions
        
        if !configuration.isEditable {
            options = options.filter { selectedOptionsIds.contains($0.id) }
        }
        
        setEmptyIfNeeded()
    }
    
    private func removeRelationOption(_ option: ObjectRelationOption) {
        Task {
            if let index = options.firstIndex(of: option) {
                options.remove(at: index)
            }
            try await objectActionsService.setArchive(objectIds: [option.id], true)
            try await relationSelectedOptionsModel.removeRelationOptionFromSelectedIfNeeded(option.id)
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
