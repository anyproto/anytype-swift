import Foundation
import SwiftUI

struct SelectPropertyListCoordinatorView: View {
    
    @StateObject var model: SelectPropertyListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    init(data: SelectPropertyListData) {
        _model = StateObject(wrappedValue: SelectPropertyListCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SelectPropertyListView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.propertyData) { data in
            PropertyOptionSettingsView(
                configuration: data.configuration,
                completion: data.completion
            )
        }
        .anytypeSheet(item: $model.deletionAlertData, cancelAction: {
            model.deletionAlertData?.completion(false)
        }, content: { data in
            model.deletionAlertView(data: data)
        })
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }
}
