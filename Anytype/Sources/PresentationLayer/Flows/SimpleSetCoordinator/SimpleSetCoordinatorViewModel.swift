import SwiftUI

@MainActor
final class SimpleSetCoordinatorViewModel: ObservableObject, SimpleSetModuleOutput {
    
    let data: EditorSimpleSetObject
    
    var pageNavigation: PageNavigation?
    var dismissAllPresented: DismissAllPresented?
    
    init(data: EditorSimpleSetObject) {
        self.data = data
    }
    
    // MARK: - SimpleSetModuleOutput
    
    func onObjectSelected(screenData: ScreenData) {
        pageNavigation?.open(screenData)
    }
}

extension SimpleSetCoordinatorViewModel {
    struct SimpleSearchData: Identifiable {
        let id = UUID()
        let items: [SimpleSearchListItem]
    }
}
