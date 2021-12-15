import Foundation
import SwiftUI

final class TagRelationEditingViewModel: ObservableObject {
    
    var onDismiss: (() -> Void)?
    
    @Published var isPresented: Bool = false
    @Published var selectedTags: [Relation.Tag.Option]
    
    let relationName: String
    
    private let relationKey: String
    private let allTags: [Relation.Tag.Option]
    
    private let detailsService: DetailsServiceProtocol
    private let relationsService: RelationsServiceProtocol
    
    private var editingActions: [TagRelationEditingAction] = []
    
    init(
        relationTag: Relation.Tag,
        detailsService: DetailsServiceProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.selectedTags = relationTag.selectedTags
        self.relationName = relationTag.name
        self.relationKey = relationTag.id
        self.allTags = relationTag.allTags

        self.detailsService = detailsService
        self.relationsService = relationsService
    }
    
    func postponeEditingAction(_ action: TagRelationEditingAction) {
        editingActions.append(action)
    }
    
    func applyEditingActions() {
        editingActions.forEach {
            switch $0 {
            case .remove(let indexSet):
                selectedTags.remove(atOffsets: indexSet)
            case .move(let source, let destination):
                selectedTags.move(fromOffsets: source, toOffset: destination)
            }
        }
        
        detailsService.updateDetails([DetailsUpdate(key: relationKey, value: selectedTags.map { $0.id }.protobufValue)])
        
        editingActions = []
    }

}

extension TagRelationEditingViewModel {
    
    var searchViewModel: TagRelationOptionSearchViewModel {
        TagRelationOptionSearchViewModel(
            relationKey: relationKey,
            availableTags: allTags.filter { !selectedTags.contains($0) },
            detailsService: detailsService,
            relationsService: relationsService
        ) { [ weak self] newTagIds in
            guard let self = self else { return }
            
            let selectedTagIds = self.selectedTags.map { $0.id }
            let newValue = selectedTagIds + newTagIds
            self.detailsService.updateDetails(
                [
                    DetailsUpdate(key: self.relationKey, value: newValue.protobufValue)
                ]
            )
            self.isPresented = false
        }
    }
    
}

extension TagRelationEditingViewModel: RelationEditingViewModelProtocol {
  
    func makeView() -> AnyView {
        AnyView(TagRelationEditingView(viewModel: self))
    }
    
}
