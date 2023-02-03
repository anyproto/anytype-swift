import Foundation

protocol WidgetObjectListViewModelProtocol: AnyObject, ObservableObject {
    var rows: [ListWidgetRow.Model] { get }
    func onAppear()
    func onDisappear()
}
