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
    @Published var options: [Relation.Object.Option] = []
    @Published var isEmpty = false
    @Published var searchText = ""
    
    let configuration: RelationModuleConfiguration
    
    private let limitedObjectTypes: [ObjectType]
    private let relationSelectedOptionsModel: RelationSelectedOptionsModelProtocol
    private let searchService: SearchServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    
    private weak var output: ObjectRelationListModuleOutput?
    
    init(
        limitedObjectTypes: [String],
        configuration: RelationModuleConfiguration,
        relationSelectedOptionsModel: RelationSelectedOptionsModelProtocol,
        searchService: SearchServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        output: ObjectRelationListModuleOutput?
    ) {
        self.limitedObjectTypes = limitedObjectTypes.compactMap { id in
            objectTypeProvider.objectTypes.first { $0.id == id }
        }
        self.configuration = configuration
        self.output = output
        self.relationSelectedOptionsModel = relationSelectedOptionsModel
        self.searchService = searchService
        self.objectActionsService = objectActionsService
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
    
    func onObjectOpen(_ option: Relation.Object.Option) {
        output?.onObjectOpen(screenData: option.editorScreenData)
    }
    
    func onObjectDuplicate(_ option: Relation.Object.Option) {
        Task {
            try await objectActionsService.duplicate(objectId: option.id)
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
    
    func onOptionDelete(_ option: Relation.Object.Option) {
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
    
    func objectRelationTypeItems() -> [ObjectRelationTypeItem]? {
        let typesNames = limitedObjectTypes.map { $0.name }
        
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
        let rawOptions = try await searchService.searchObjectsByTypes(
            text: text,
            typeIds: limitedObjectTypes.map { $0.id },
            excludedObjectIds: [],
            spaceId: configuration.spaceId
        ).map { Relation.Object.Option(objectDetails: $0) }
        
        options = rawOptions.reordered(
            by: selectedOptionsIds
        ) { $0.id }
        
        if !configuration.isEditable {
            options = options.filter { selectedOptionsIds.contains($0.id) }
        }
        
        setEmptyIfNeeded()
    }
    
    private func removeRelationOption(_ option: Relation.Object.Option) {
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
