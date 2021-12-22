import Foundation
import SwiftUI

final class RelationOptionsViewModel: ObservableObject {
    
    var dismissHandler: (() -> Void)?
    
    @Published var isPresented: Bool = false
    @Published var selectedOptions: [RelationOptionProtocol] = []
    
    let title: String
    let emptyPlaceholder: String
    
    private let type: RelationOptionsType
    private let relationKey: String
    private let relationsService: RelationsServiceProtocol
    private var editingActions: [RelationOptionEditingAction] = []
    
    init(
        type: RelationOptionsType,
        title: String,
        relationKey: String,
        selectedOptions: [RelationOptionProtocol],
        relationsService: RelationsServiceProtocol
    ) {
        self.type = type
        self.title = title
        self.emptyPlaceholder = type.placeholder
        self.relationKey = relationKey
        self.selectedOptions = selectedOptions
        self.relationsService = relationsService
    }
    
}

extension RelationOptionsViewModel {
    
    func postponeEditingAction(_ action: RelationOptionEditingAction) {
        editingActions.append(action)
    }
    
    func applyEditingActions() {
        editingActions.forEach {
            switch $0 {
            case .remove(let indexSet):
                selectedOptions.remove(atOffsets: indexSet)
            case .move(let source, let destination):
                selectedOptions.move(fromOffsets: source, toOffset: destination)
            }
        }
        
        relationsService.updateRelation(
            relationKey: relationKey,
            value: selectedOptions.map { $0.id }.protobufValue
        )
        
        editingActions = []
    }
    
    func makeSearchView() -> AnyView {
        switch type {
        case .objects:
            return AnyView(RelationObjectsSearchView(viewModel: objectsSearchViewModel))
        case .tags(let allTags):
            return AnyView(TagRelationOptionSearchView(viewModel: searchViewModel(allTags: allTags)))
        }
    }
    
    private var objectsSearchViewModel: RelationObjectsSearchViewModel {
        RelationObjectsSearchViewModel(
            excludeObjectIds: selectedOptions.map { $0.id }
        ) { [weak self] newObjectIds in
            guard let self = self else { return }
            
            let selectedObjectIds = self.selectedOptions.map { $0.id }
            let newValue = selectedObjectIds + newObjectIds
            self.relationsService.updateRelation(
                relationKey: self.relationKey,
                value: newValue.protobufValue
            )
            self.isPresented = false
        }
    }
    
    private func searchViewModel(allTags: [Relation.Tag.Option]) -> TagRelationOptionSearchViewModel {
        TagRelationOptionSearchViewModel(
            relationKey: relationKey,
            availableTags: allTags.filter { tag in
                !selectedOptions.contains { $0.id == tag.id }
            },
            relationsService: relationsService
        ) { [weak self] newTagIds in
            guard let self = self else { return }
            
            let selectedTagIds = self.selectedOptions.map { $0.id }
            let newValue = selectedTagIds + newTagIds
            self.relationsService.updateRelation(
                relationKey: self.relationKey,
                value: newValue.protobufValue
            )
            self.isPresented = false
        }
    }
    
    
    
}

extension RelationOptionsViewModel: RelationEditingViewModelProtocol {
    
    func makeView() -> AnyView {
        AnyView(RelationOptionsView(viewModel: self))
    }
    
}
