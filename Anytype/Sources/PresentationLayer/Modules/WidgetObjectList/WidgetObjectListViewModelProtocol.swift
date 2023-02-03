import Foundation

protocol WidgetObjectListViewModelProtocol: AnyObject, ObservableObject {
    var title: String { get }
    var rows: [ListWidgetRow.Model] { get }
    var editorViewType: EditorViewType { get }
    
    func onAppear()
    func onDisappear()
}
