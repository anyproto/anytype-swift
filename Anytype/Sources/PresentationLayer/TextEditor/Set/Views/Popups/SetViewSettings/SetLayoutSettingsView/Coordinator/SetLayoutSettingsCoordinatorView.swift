import SwiftUI

struct SetLayoutSettingsCoordinatorView: View {
    @StateObject var model: SetLayoutSettingsCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(item: $model.imagePreviewData) { data in
                model.imagePreview(data: data)
                    .mediumPresentationDetents()
            }
    }
}
