import Foundation
import SwiftUI

struct ObjectRelationListCoordinatorView: View {
    
    @StateObject var model: ObjectRelationListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        relationList
            .anytypeSheet(item: $model.deletionAlertData, cancelAction: {
                model.deletionAlertData?.completion(false)
            }, content: { data in
                model.deletionAlertView(data: data)
            })
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
    
    private var relationList: some View {
        switch model.mode {
        case let .object(limitedObjectTypes):
            let limitedObjectTypes = model.obtainLimitedObjectTypes(with: limitedObjectTypes)
            return ObjectRelationListView(
                objectId: model.configuration.objectId,
                configuration: model.configuration,
                selectedOptionsIds: model.selectedOptionsIds, 
                interactor: ObjectRelationListInteractor(
                    spaceId: model.configuration.spaceId,
                    limitedObjectTypes: limitedObjectTypes
                ),
                output: model
            )
        case .file:
            return ObjectRelationListView(
                objectId: model.configuration.objectId,
                configuration: model.configuration,
                selectedOptionsIds: model.selectedOptionsIds,
                interactor: FileRelationListInteractor(
                    spaceId: model.configuration.spaceId
                ),
                output: model
            )
        }
    }
}

extension ObjectRelationListCoordinatorView {
    init(
        mode: ObjectRelationListMode,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListCoordinatorModuleOutput?
    ) {
        _model = StateObject(
            wrappedValue: ObjectRelationListCoordinatorViewModel(
                mode: mode,
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds,
                output: output
            )
        )
    }
}
