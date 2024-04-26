import SwiftUI
import Services

@MainActor
protocol SetRelationsCoordinatorOutput: AnyObject {
    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void)
}

@MainActor
final class SetRelationsCoordinatorViewModel: ObservableObject, SetRelationsCoordinatorOutput {
    @Published var addRelationsData: AddRelationsData?
    
    let setDocument: SetDocumentProtocol
    let viewId: String
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.addNewRelationCoordinator = addNewRelationCoordinator
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
