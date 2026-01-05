import SwiftUI

struct SpaceCreateCoordinatorView: View {
    
    @StateObject private var model: SpaceCreateCoordinatorViewModel
    
    init(data: SpaceCreateData) {
        self._model = StateObject(wrappedValue: SpaceCreateCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SpaceCreateView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.localObjectIconPickerData) {
            LocalObjectIconPickerView(data: $0)
        }
        .sheet(item: $model.homePagePickerData) { data in
            HomePagePickerView(spaceId: data.spaceId) {
                model.onHomePagePickerFinished()
            }.interactiveDismissDisabled(true)
        }
    }
}
