import Foundation
import SwiftUI

struct SelectRelationListCoordinatorView: View {
    
    @StateObject var model: SelectRelationListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.selectRelationListModule()
            .sheet(item: $model.relationData) { data in
                RelationOptionSettingsView(
                    configuration: data.configuration,
                    completion: data.completion
                )
            }
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
