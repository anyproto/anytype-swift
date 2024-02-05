import Foundation
import SwiftUI

struct ObjectRelationListCoordinatorView: View {
    
    @StateObject var model: ObjectRelationListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.objectRelationListModule()
            .anytypeSheet(item: $model.deletionAlertData) { data in
                model.deletionAlertView(data: data)
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
