import Foundation
import SwiftUI

struct ObjectSettingsCoordinatorView: View {
    
    @StateObject var model: ObjectSettingsCoordinatorViewModel
    
    var body: some View {
        ObjectSettingsView(objectId: model.objectId, output: model)
            .sheet(item: $model.coverPickerData) {
                ObjectCoverPicker(data: $0)
            }
    }
}
