import SwiftUI
import Services
import AnytypeCore


@MainActor
protocol SetPropertiesCoordinatorOutput: AnyObject {
    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void)
}

@MainActor
final class SetPropertiesCoordinatorViewModel:
    ObservableObject,
    SetPropertiesCoordinatorOutput
{
    @Published var relationsSearchData: RelationsSearchData?
    
    let setDocument: any SetDocumentProtocol
    let viewId: String
    
    init(setDocument: some SetDocumentProtocol, viewId: String) {
        self.setDocument = setDocument
        self.viewId = viewId
    }
    
    // MARK: - EditorSetPropertiesCoordinatorOutput

    func onAddButtonTap(completion: @escaping (RelationDetails, _ isNew: Bool) -> Void) {
        
        // In case we are working with set in object type we have to update relations of this type as well
        var typeDetails: ObjectDetails? = nil
        if let details = setDocument.details, details.isObjectType {
            typeDetails = details
        }
        
        relationsSearchData = RelationsSearchData(
            objectId: setDocument.objectId,
            spaceId: setDocument.spaceId,
            excludedRelationsIds: setDocument.sortedRelations(for: viewId).map(\.id),
            target: .dataview(objectId: setDocument.objectId, activeViewId: setDocument.activeView.id, typeDetails: typeDetails),
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
