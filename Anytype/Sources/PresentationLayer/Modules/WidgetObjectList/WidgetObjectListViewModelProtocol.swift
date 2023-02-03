import Foundation

protocol WidgetObjectListViewModelProtocol: AnyObject, ObservableObject {
    var title: String { get }
    var rows: [ListRowConfiguration] { get }
    var editorViewType: EditorViewType { get }
    
    func onAppear()
    func onDisappear()
    func didAskToSearch(text: String)
}
