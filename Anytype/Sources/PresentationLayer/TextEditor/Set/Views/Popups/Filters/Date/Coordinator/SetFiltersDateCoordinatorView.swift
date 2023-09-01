import SwiftUI

struct SetFiltersDateCoordinatorView: View {
    @StateObject var model: SetFiltersDateCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(item: $model.filtersDaysData) { data in
                model.filtersDaysView(data)
            }
    }
}
