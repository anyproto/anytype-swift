import SwiftUI

struct RelationCalendarCoordinatorView: View {
    
    @StateObject private var model: RelationCalendarCoordinatorViewModel
    
    init(date: Date?, configuration: RelationModuleConfiguration) {
        self._model = StateObject(wrappedValue: RelationCalendarCoordinatorViewModel(date: date, configuration: configuration))
    }
    
    var body: some View {
        RelationCalendarView(
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
