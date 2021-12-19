import Foundation

final class RelationObjectsEditingViewModel: ObservableObject {
    
    var dismissHandler: (() -> Void)?
    
    @Published var isPresented: Bool = false
    @Published var selectedObjects: [Relation.Object.Option]
    
    let relationName: String
    
    private let relationKey: String
    private let relationsService: RelationsServiceProtocol
    private var editingActions: [TagRelationEditingAction] = []
    
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
