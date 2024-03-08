import Foundation
import SwiftUI

struct SelectRelationListCoordinatorView: View {
    
    @StateObject var model: SelectRelationListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    init(
        style: SelectRelationListStyle,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String]
    ) {
        _model = StateObject(
            wrappedValue: SelectRelationListCoordinatorViewModel(
                style: style,
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds
            )
        )
    }
    
    var body: some View {
        SelectRelationListView(
            style: model.style,
            configuration: model.configuration,
            selectedOptionsIds: model.selectedOptionsIds,
            output: model
        )
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
