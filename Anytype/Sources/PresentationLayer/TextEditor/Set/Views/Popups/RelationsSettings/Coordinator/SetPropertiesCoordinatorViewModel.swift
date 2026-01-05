import SwiftUI
import Services
import AnytypeCore


@MainActor
protocol SetPropertiesCoordinatorOutput: AnyObject {
    func onAddButtonTap(completion: @escaping (PropertyDetails, _ isNew: Bool) -> Void)
}

@MainActor
@Observable
final class SetPropertiesCoordinatorViewModel: SetPropertiesCoordinatorOutput {
    var relationsSearchData: PropertiesSearchData?

    @ObservationIgnored
    let setDocument: any SetDocumentProtocol
    @ObservationIgnored
    let viewId: String
    
    init(setDocument: some SetDocumentProtocol, viewId: String) {
        self.setDocument = setDocument
        self.viewId = viewId
    }
    
    // MARK: - EditorSetPropertiesCoordinatorOutput

    func onAddButtonTap(completion: @escaping (PropertyDetails, _ isNew: Bool) -> Void) {
        
        // In case we are working with set in object type we have to update relations of this type as well
        var typeDetails: ObjectDetails? = nil
        if let details = setDocument.details, details.isObjectType {
            typeDetails = details
        }
        
        relationsSearchData = PropertiesSearchData(
            objectId: setDocument.objectId,
            spaceId: setDocument.spaceId,
            excludedRelationsIds: setDocument.sortedRelations(for: viewId).map(\.id),
            target: .dataview(objectId: setDocument.objectId, activeViewId: setDocument.activeView.id, typeDetails: typeDetails),
            onRelationSelect: { relationDetails, isNew in
                AnytypeAnalytics.instance().logAddExistingOrCreateRelation(
                    format: relationDetails.format,
                    isNew: isNew,
                    type: .dataview,
                    key: relationDetails.analyticsKey
                )
            }
        )
    }
}
