import Foundation

// TODO: Delete it
final class WidgetObjectListEmptyViewModel: ObservableObject, WidgetObjectListViewModelProtocol {
    
    var title = "Empty Screen"
    var editorViewType: EditorViewType = .favorites
    var rows: [ListRowConfiguration] = []
    
    func onAppear() {
    }
    
    func onDisappear() {
    }
    
    func didAskToSearch(text: String) {
    }
}
