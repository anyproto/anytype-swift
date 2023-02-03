import Foundation

// TODO: Delete it
final class WidgetObjectListEmptyViewModel: ObservableObject, WidgetObjectListViewModelProtocol {
    
    var title = "Empty Screen"
    var editorViewType: EditorViewType = .favorites
    var rows: [ListWidgetRow.Model] = []
    
    func onAppear() {
    }
    
    func onDisappear() {
    }
}
