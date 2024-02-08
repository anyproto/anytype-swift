import Foundation
import SwiftUI

struct ObjectRelationListCoordinatorView: View {
    
    @StateObject var model: ObjectRelationListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.relationListModule()
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
