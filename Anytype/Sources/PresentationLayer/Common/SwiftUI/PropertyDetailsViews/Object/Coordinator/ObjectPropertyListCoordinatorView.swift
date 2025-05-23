import Foundation
import SwiftUI

struct ObjectPropertyListCoordinatorView: View {
    
    @StateObject var model: ObjectPropertyListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    init(data: ObjectPropertyListData, output: (any ObjectPropertyListCoordinatorModuleOutput)?) {
        _model = StateObject(wrappedValue: ObjectPropertyListCoordinatorViewModel(data: data, output: output))
    }
    
    var body: some View {
        ObjectPropertyListView(
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
