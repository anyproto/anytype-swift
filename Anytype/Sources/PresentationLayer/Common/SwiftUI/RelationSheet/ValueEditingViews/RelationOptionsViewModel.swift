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
    private var editingActions: [TagRelationEditingAction] = []
    
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
    
    #warning("TODO: rename TagRelationEditingAction")
    func postponeEditingAction(_ action: TagRelationEditingAction) {
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
    
}

extension RelationOptionsViewModel: RelationEditingViewModelProtocol {
    
    func makeView() -> AnyView {
        AnyView(RelationOptionsView(viewModel: self))
    }
    
}
