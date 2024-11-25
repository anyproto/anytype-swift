import SwiftUI

@MainActor
final class DateCoordinatorViewModel: ObservableObject, DateModuleOutput {
    
    let objectId: String
    let spaceId: String
    
    @Published var showSyncStatusInfo = false
    @Published var searchData: SimpleSearchData?
    @Published var calendarData: CalendarData?
    
    var pageNavigation: PageNavigation?
    
    init(data: EditorDateObject) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
    }
    
    // MARK: - DateModuleOutput
    
    func onSyncStatusTap() {
        showSyncStatusInfo.toggle()
    }
    
    func onObjectTap(data: EditorScreenData) {
        pageNavigation?.push(data)
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
