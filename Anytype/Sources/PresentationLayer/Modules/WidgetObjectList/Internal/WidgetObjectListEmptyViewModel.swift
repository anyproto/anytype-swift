import Foundation
import BlocksModels
import Combine

// TODO: Delete it
final class WidgetObjectListEmptyViewModel: ObservableObject, WidgetObjectListInternalViewModelProtocol {
    
    var title = "Empty Screen"
    var editorViewType: EditorViewType = .favorites
    var rowDetailsPublisher: AnyPublisher<[ObjectDetails], Never> {
        $rowDetails.eraseToAnyPublisher()
    }
    
    @Published private var rowDetails: [ObjectDetails] = []
    
    func onAppear() {
    }
    
    func onDisappear() {
    }
}
