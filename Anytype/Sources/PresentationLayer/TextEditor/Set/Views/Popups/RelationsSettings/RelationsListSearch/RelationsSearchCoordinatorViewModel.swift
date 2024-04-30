import SwiftUI
import Services

@MainActor
protocol RelationsSearchCoordinatorOutput: AnyObject {
    func onRelationSelection(relationDetails: RelationDetails, isNew: Bool)
}

@MainActor
final class RelationsSearchCoordinatorViewModel: ObservableObject, NewRelationCoordinatorViewOutput {
    
    @Published var newRelationData: NewRelationData?
    @Published var toastData: ToastBarData = .empty
    @Published var dismiss = false
    
    let data: RelationsSearchData
    private weak var output: RelationsSearchCoordinatorOutput?
    
    init(
        data: RelationsSearchData,
        output: RelationsSearchCoordinatorOutput?
    ) {
        self.data = data
        self.output = output
    }
    
    func onShowCreateNewRelation(name: String) {
        newRelationData = NewRelationData(
            name: name,
            document: data.document,
            target: data.target
        )
    }
    
    func onSelectRelation(_ relation: RelationDetails) {
        output?.onRelationSelection(relationDetails: relation, isNew: false)
        toastData = ToastBarData(text: Loc.Relation.addedToLibrary(relation.name), showSnackBar: true)
        dismiss.toggle()
    }
    
    // MARK: - NewRelationCoordinatorViewOutput
    
    func didCreateRelation(_ relation: RelationDetails) {
        output?.onRelationSelection(relationDetails: relation, isNew: true)
        dismiss.toggle()
    }
}
