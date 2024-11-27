import SwiftUI

struct DateCoordinatorView: View {
    
    @StateObject private var model: DateCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorDateObject) {
        self._model = StateObject(wrappedValue: DateCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        DateView(
            date: model.initialData.date,
            spaceId: model.initialData.spaceId,
            output: model
        )
        .onAppear {
            model.pageNavigation = pageNavigation
        }
        .anytypeSheet(isPresented: $model.showSyncStatusInfo) {
            SyncStatusInfoView(spaceId: model.initialData.spaceId)
        }
        .sheet(item: $model.searchData) { data in
            SimpleSearchListView(items: data.items)
                .mediumPresentationDetents()
        }
        .sheet(item: $model.calendarData) { data in
            CalendarView(data: data)
                .applyDragIndicator()
                .fitPresentationDetents()
        }
    }
}

#Preview {
    DateCoordinatorView(data: EditorDateObject(date: Date(), spaceId: ""))
}
