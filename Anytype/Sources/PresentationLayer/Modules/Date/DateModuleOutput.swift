import Foundation

@MainActor
protocol DateModuleOutput: AnyObject {
    func onSyncStatusTap()
    func onObjectTap(data: ScreenData)
    func onSearchListTap(items: [SimpleSearchListItem])
    func onCalendarTap(with currentDate: Date, completion: @escaping (Date) -> Void)
}
