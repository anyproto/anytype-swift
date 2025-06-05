import SwiftUI

struct PropertyCalendarCoordinatorView: View {
    
    @StateObject private var model: PropertyCalendarCoordinatorViewModel
    
    init(date: Date?, configuration: PropertyModuleConfiguration) {
        self._model = StateObject(wrappedValue: PropertyCalendarCoordinatorViewModel(date: date, configuration: configuration))
    }
    
    var body: some View {
        PropertyCalendarView(
            date: model.date,
            configuration: model.configuration,
            output: model
        )
        .sheet(item: $model.dateObjectData) { data in
            DateCoordinatorView(data: data.data)
                .applyDragIndicator()
        }
        .fitPresentationDetents()
    }
}
