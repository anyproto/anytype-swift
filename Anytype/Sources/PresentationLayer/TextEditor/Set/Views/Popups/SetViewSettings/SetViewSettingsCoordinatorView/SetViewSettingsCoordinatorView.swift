import SwiftUI

struct SetViewSettingsCoordinatorView: View {
    @StateObject var model: SetViewSettingsCoordinatorViewModel
    
    var body: some View {
        SetViewSettingsList(
            data: model.data,
            output: model
        )
        .sheet(isPresented: $model.showLayouts) {
            SetLayoutSettingsCoordinatorView(
                setDocument: model.data.setDocument,
                viewId: model.data.viewId
            )
            .mediumPresentationDetents()
        }
        .sheet(isPresented: $model.showRelations) {
            model.relationsList()
        }
        .sheet(isPresented: $model.showFilters) {
            model.setFiltersList()
        }
        .sheet(isPresented: $model.showSorts) {
            model.setSortsList()
        }
    }
}
