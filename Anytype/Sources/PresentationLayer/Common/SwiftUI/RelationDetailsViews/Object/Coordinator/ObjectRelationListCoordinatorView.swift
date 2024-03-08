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
            ObjectRelationListView(
                objectId: model.configuration.objectId,
                limitedObjectTypes: model.obtainLimitedObjectTypes(with: limitedObjectTypes),
                configuration: model.configuration,
                selectedOptionsIds: model.selectedOptionsIds,
                output: model
            )
        case .file:
            ObjectRelationListView(
                objectId: model.configuration.objectId,
                limitedObjectTypes: [],
                configuration: model.configuration,
                selectedOptionsIds: model.selectedOptionsIds,
                output: model
            )
        }
    }
}
