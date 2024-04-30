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
            SetRelationsCoordinatorView(
                setDocument: model.data.setDocument,
                viewId: model.data.viewId
            )
        }
        .sheet(isPresented: $model.showFilters) {
            SetFiltersListCoordinatorView(
                setDocument: model.data.setDocument,
                viewId: model.data.viewId,
                subscriptionDetailsStorage: model.data.subscriptionDetailsStorage
            )
        }
        .sheet(isPresented: $model.showSorts) {
            SetSortsListCoordinatorView(
                setDocument: model.data.setDocument,
                viewId: model.data.viewId
            )
        }
    }
}
