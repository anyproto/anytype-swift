import Foundation
import SwiftUI

struct ObjectSettingsCoordinatorView: View {
    
    @StateObject var model: ObjectSettingsCoordinatorViewModel
    
    var body: some View {
        ObjectSettingsView(objectId: model.objectId, output: model, actionHandler: model.objectSettingsHandler)
            .sheet(item: $model.coverPickerData) {
                ObjectCoverPicker(data: $0)
            }
    }
}
