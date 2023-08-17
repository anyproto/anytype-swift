import SwiftUI

struct SetViewSettingsNavigationView: View {
    @StateObject var model: SetViewSettingsNavigationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            model.list()
        }
        .sheet(isPresented: $model.showRelations) {
//            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $model.showFilters) {
            
        }
        .sheet(isPresented: $model.showSorts) {
            
        }
    }
}
