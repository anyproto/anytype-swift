import SwiftUI

struct DateCoordinatorView: View {

    @State private var model: DateCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismissAllPresented) private var dismissAllPresented

    init(data: EditorDateObject) {
        _model = State(initialValue: DateCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        DateView(
            date: model.initialData.date,
            spaceId: model.initialData.spaceId,
            output: model
        )
        .onAppear {
            model.pageNavigation = pageNavigation
            model.dismissAllPresented = dismissAllPresented
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
