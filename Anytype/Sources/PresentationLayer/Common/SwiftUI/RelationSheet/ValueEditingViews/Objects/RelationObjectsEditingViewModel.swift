import Foundation
import SwiftUI

final class RelationObjectsEditingViewModel: ObservableObject {
    
    var dismissHandler: (() -> Void)?
    
    @Published var isPresented: Bool = false
    @Published var selectedObjects: [Relation.Object.Option]
    
    let relationName: String
    
    private let relationKey: String
    private let relationsService: RelationsServiceProtocol
    private var editingActions: [RelationOptionEditingAction] = []
    
    init(
        relationObject: Relation.Object,
        relationsService: RelationsServiceProtocol
    ) {
        self.selectedObjects = relationObject.selectedObjects
        self.relationName = relationObject.name
        self.relationKey = relationObject.id

        self.relationsService = relationsService
    }
    
}

extension RelationObjectsEditingViewModel {
    
    func postponeEditingAction(_ action: RelationOptionEditingAction) {
        editingActions.append(action)
    }
    
    func applyEditingActions() {
        editingActions.forEach {
            switch $0 {
            case .remove(let indexSet):
                selectedObjects.remove(atOffsets: indexSet)
            case .move(let source, let destination):
                selectedObjects.move(fromOffsets: source, toOffset: destination)
            }
        }
        
        relationsService.updateRelation(
            relationKey: relationKey,
            value: selectedObjects.map { $0.id }.protobufValue
        )
        
        editingActions = []
    }
    
    var relationObjectsSearchViewModel: RelationObjectsSearchViewModel {
        RelationObjectsSearchViewModel(
            excludeObjectIds: selectedObjects.map { $0.id }
        ) { [ weak self] newObjectIds in
            guard let self = self else { return }
            
            let selectedObjectIds = self.selectedObjects.map { $0.id }
            let newValue = selectedObjectIds + newObjectIds
            self.relationsService.updateRelation(
                relationKey: self.relationKey,
                value: newValue.protobufValue
            )
            self.isPresented = false
        }
    }
}

extension RelationObjectsEditingViewModel: RelationEditingViewModelProtocol {
    
    func makeView() -> AnyView {
        AnyView(RelationObjectsEditingView(viewModel: self))
    }
    
}
