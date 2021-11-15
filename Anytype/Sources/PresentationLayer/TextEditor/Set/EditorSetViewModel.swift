import Combine
import BlocksModels

final class EditorSetViewModel: ObservableObject {
    let document: BaseDocument
    var router: EditorRouterProtocol!
    
    init(document: BaseDocument) {
        self.document = document
//        document.updatePublisher.sink { [weak self] in
//            self?.onDashboardChange(updateResult: $0)
//        }.store(in: &cancellables)
        if !document.open() {
            // TODO: Return
        }
    }
    
    func onAppear() {
        
    }
}
