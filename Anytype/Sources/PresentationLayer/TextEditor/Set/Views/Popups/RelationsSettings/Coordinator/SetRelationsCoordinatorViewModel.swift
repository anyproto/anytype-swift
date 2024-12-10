import SwiftUI
import Services

@MainActor
protocol SetRelationsCoordinatorOutput: AnyObject {
    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void)
}

@MainActor
final class SetRelationsCoordinatorViewModel:
    ObservableObject,
    SetRelationsCoordinatorOutput
{
    @Published var relationsSearchData: RelationsSearchData?
    
    let setDocument: any SetDocumentProtocol
    let viewId: String
    
    init(setDocument: some SetDocumentProtocol, viewId: String) {
        self.setDocument = setDocument
        self.viewId = viewId
    }
    
    // MARK: - EditorSetRelationsCoordinatorOutput

    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void) {
        relationsSearchData = RelationsSearchData(
            objectId: setDocument.objectId,
            spaceId: setDocument.spaceId,
            excludedRelationsIds: setDocument.sortedRelations(for: viewId).map(\.id),
            target: .dataview(activeViewId: setDocument.activeView.id), 
            onRelationSelect: { [weak self] relationDetails, isNew in
                guard let self else { return }
                AnytypeAnalytics.instance().logAddExistingOrCreateRelation(
                    format: relationDetails.format,
                    isNew: isNew,
                    type: .dataview,
                    key: relationDetails.analyticsKey,
                    spaceId: setDocument.spaceId
                )
            }
        )
    }
}
