import SwiftUI

struct SetViewSettingsCoordinatorView: View {
    @StateObject var model: SetViewSettingsCoordinatorViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            model.list()
        }
        .sheet(isPresented: $model.showObjects) {}
        .sheet(isPresented: $model.showLayouts) {}
        .sheet(isPresented: $model.showRelations) {}
        .sheet(isPresented: $model.showFilters) {}
        .sheet(isPresented: $model.showSorts) {}
    }
}
