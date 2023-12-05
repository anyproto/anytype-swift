import SwiftUI
import Services

@MainActor
protocol SetRelationsCoordinatorOutput: AnyObject {
    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void)
}

@MainActor
final class SetRelationsCoordinatorViewModel: ObservableObject, SetRelationsCoordinatorOutput {
    @Published var addRelationsData: AddRelationsData?
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let setRelationsViewModuleAssembly: SetRelationsViewModuleAssemblyProtocol
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        setRelationsViewModuleAssembly: SetRelationsViewModuleAssemblyProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.setRelationsViewModuleAssembly = setRelationsViewModuleAssembly
        self.addNewRelationCoordinator = addNewRelationCoordinator
    }
    
    func list() -> AnyView {
        setRelationsViewModuleAssembly.make(
            setDocument: setDocument,
            viewId: viewId,
            output: self
        )
    }
    
    // MARK: - EditorSetRelationsCoordinatorOutput

    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void) {
        addRelationsData = AddRelationsData(completion: completion)
    }
    
    func newRelationView(data: AddRelationsData) -> NewSearchView {
        addNewRelationCoordinator.addNewRelationView(
            document: setDocument.document,
            excludedRelationsIds: setDocument.sortedRelations(for: viewId).map(\.id),
            target: .dataview(activeViewId: setDocument.activeView.id),
            onCompletion: data.completion
        )
    }
}

extension SetRelationsCoordinatorViewModel {
    struct AddRelationsData: Identifiable {
        let id = UUID()
        let completion: (RelationDetails, _ isNew: Bool) -> Void
    }
}
