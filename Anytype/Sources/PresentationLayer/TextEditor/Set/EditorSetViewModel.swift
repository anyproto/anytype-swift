import Combine
import BlocksModels
import AnytypeCore

final class EditorSetViewModel: ObservableObject {
    let document: BaseDocument
    var router: EditorRouterProtocol!
    var dataView: BlockDataview!
    
    init(document: BaseDocument) {
        self.document = document
//        document.updatePublisher.sink { [weak self] in
//            self?.onDashboardChange(updateResult: $0)
//        }.store(in: &cancellables)
        
        if !document.open() {
            // TODO: Return
        }
        
        let dataViews = document.flattenBlocks.compactMap { block -> BlockDataview? in
            if case .dataView(let data) = block.information.content {
                return data
            }
            return nil
        }
        anytypeAssert(dataViews.isNotEmpty, "No dataview block for set", domain: .editorSet)
        dataView = dataViews[0]
    }
    
    func onAppear() {
        
    }
}
