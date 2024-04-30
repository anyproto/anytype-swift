import SwiftUI
import Services

@MainActor
final class RelationsSearchCoordinatorViewModel: ObservableObject, NewRelationCoordinatorViewOutput {
    
    @Published var newRelationData: NewRelationData?
    @Published var toastData: ToastBarData = .empty
    @Published var dismiss = false
    
    let data: RelationsSearchData
    
    init(data: RelationsSearchData) {
        self.data = data
    }
    
    func onShowCreateNewRelation(name: String) {
        newRelationData = NewRelationData(
            name: name,
            document: data.document,
            target: data.target
        )
    }
    
    func onSelectRelation(_ relation: RelationDetails) {
        data.onRelationSelect(relation, false)
        toastData = ToastBarData(text: Loc.Relation.addedToLibrary(relation.name), showSnackBar: true)
        dismiss.toggle()
    }
    
    // MARK: - NewRelationCoordinatorViewOutput
    
    func didCreateRelation(_ relation: RelationDetails) {
        data.onRelationSelect(relation, true)
        dismiss.toggle()
    }
}
