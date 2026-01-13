import SwiftUI

@MainActor
@Observable
final class DateCoordinatorViewModel: DateModuleOutput {

    let initialData: EditorDateObject

    var showSyncStatusInfo = false
    var searchData: SimpleSearchData?
    var calendarData: CalendarData?
    
    var pageNavigation: PageNavigation?
    var dismissAllPresented: DismissAllPresented?
    
    init(data: EditorDateObject) {
        self.initialData = data
    }
    
    // MARK: - DateModuleOutput
    
    func onSyncStatusTap() {
        showSyncStatusInfo.toggle()
    }
    
    func onObjectTap(data: ScreenData) {
        Task {
            await dismissAllPresented?()
            pageNavigation?.open(data)
        }
    }
    
    func onSearchListTap(items: [SimpleSearchListItem]) {
        searchData = SimpleSearchData(items: items)
    }
    
    func onCalendarTap(with currentDate: Date, completion: @escaping (Date) -> Void) {
        calendarData = CalendarData(
            date: currentDate,
            onDateChanged: completion
        )
    }
}

extension DateCoordinatorViewModel {
    struct SimpleSearchData: Identifiable {
        let id = UUID()
        let items: [SimpleSearchListItem]
    }
}
