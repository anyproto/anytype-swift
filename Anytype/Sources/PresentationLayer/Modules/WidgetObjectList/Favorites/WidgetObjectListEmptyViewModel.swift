import Foundation

// TODO: Delete it
final class WidgetObjectListEmptyViewModel: ObservableObject, WidgetObjectListViewModelProtocol {
    
    
    var rows: [ListWidgetRow.Model] = []
    
    func onAppear() {
    }
    
    func onDisappear() {
    }
}
