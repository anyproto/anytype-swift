import SwiftUI

struct SetViewSettingsCoordinatorView: View {
    @StateObject var model: SetViewSettingsCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(isPresented: $model.showObjects) {}
            .sheet(isPresented: $model.showLayouts) {}
            .sheet(isPresented: $model.showRelations) {}
            .sheet(isPresented: $model.showFilters) {}
            .sheet(isPresented: $model.showSorts) {}
    }
}
