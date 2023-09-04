import SwiftUI
import Services

@MainActor
protocol EditorSetRelationsCoordinatorOutput: AnyObject {
    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void)
}

@MainActor
final class EditorSetRelationsCoordinatorViewModel: ObservableObject, EditorSetRelationsCoordinatorOutput {
    @Published var addRelationsData: AddRelationsData?
    
    private let setDocument: SetDocumentProtocol
    private let setRelationsViewModuleAssembly: EditorSetRelationsViewModuleAssemblyProtocol
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        setRelationsViewModuleAssembly: EditorSetRelationsViewModuleAssemblyProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    ) {
        self.setDocument = setDocument
        self.setRelationsViewModuleAssembly = setRelationsViewModuleAssembly
        self.addNewRelationCoordinator = addNewRelationCoordinator
    }
    
    func list() -> AnyView {
        setRelationsViewModuleAssembly.make(
            setDocument: setDocument,
            output: self,
            router: nil
        )
    }
    
    // MARK: - EditorSetRelationsCoordinatorOutput

    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void) {
        addRelationsData = AddRelationsData(completion: completion)
    }
    
    func newRelationView(data: AddRelationsData) -> NewSearchView {
        addNewRelationCoordinator.addNewRelationView(
            document: setDocument.document,
            excludedRelationsIds: setDocument.sortedRelations.map(\.id),
            target: .dataview(activeViewId: setDocument.activeView.id),
            onCompletion: data.completion
        )
    }
}

extension EditorSetRelationsCoordinatorViewModel {
    struct AddRelationsData: Identifiable {
        let id = UUID()
        let completion: (RelationDetails, _ isNew: Bool) -> Void
    }
}
