import Foundation
import SwiftUI

struct ObjectRelationListCoordinatorView: View {
    
    @StateObject var model: ObjectRelationListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    init(data: ObjectRelationListData, output: ObjectRelationListCoordinatorModuleOutput?) {
        _model = StateObject(wrappedValue: ObjectRelationListCoordinatorViewModel(data: data, output: output))
    }
    
    var body: some View {
        ObjectRelationListView(
            data: model.data,
            output: model
        )
        .anytypeSheet(item: $model.deletionAlertData, cancelAction: {
            model.deletionAlertData?.completion(false)
        }, content: { data in
            model.deletionAlertView(data: data)
        })
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
