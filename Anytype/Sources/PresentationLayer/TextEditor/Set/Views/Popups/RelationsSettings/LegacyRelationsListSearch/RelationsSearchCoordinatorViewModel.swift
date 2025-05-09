import SwiftUI
import Services

@MainActor
final class RelationsSearchCoordinatorViewModel: ObservableObject, RelationInfoCoordinatorViewOutput {
    
    @Published var newRelationData: RelationInfoData?
    @Published var toastData: ToastBarData?
    @Published var dismiss = false
    
    let data: RelationsSearchData
    
    init(data: RelationsSearchData) {
        self.data = data
    }
    
    func onShowCreateNewRelation(name: String) {
        newRelationData = RelationInfoData(
            name: name,
            objectId: data.objectId,
            spaceId: data.spaceId,
            target: data.target,
            mode: .create(format: nil)
        )
    }
    
    func onSelectRelation(_ relation: RelationDetails) {
        data.onRelationSelect(relation, false)
        toastData = ToastBarData(Loc.Fields.created(relation.name))
        dismiss.toggle()
    }
    
    // MARK: - RelationInfoCoordinatorViewOutput
    
    func didPressConfirm(_ relation: RelationDetails) {
        data.onRelationSelect(relation, true)
        dismiss.toggle()
    }
}
