import SwiftUI

struct SetViewSettingsCoordinatorView: View {
    @StateObject var model: SetViewSettingsCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(isPresented: $model.showObjects) {}
            .sheet(isPresented: $model.showLayouts) {
                model.setLayoutSettings()
                    .mediumPresentationDetents()
            }
            .sheet(isPresented: $model.showRelations) {}
            .sheet(isPresented: $model.showFilters) {
                model.setFiltersList()
            }
            .sheet(isPresented: $model.showSorts) {
                model.setSortsList()
            }
    }
}
