import SwiftUI

@MainActor
final class DateCoordinatorViewModel: ObservableObject, DateModuleOutput {
    
    let objectId: String
    let spaceId: String
    
    @Published var showSyncStatusInfo = false
    @Published var searchData: SimpleSearchData?
    
    var pageNavigation: PageNavigation?
    
    init(data: EditorDateObject) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
    }
    
    // MARK: - DateModuleOutput
    
    func onSyncStatusTap() {
        showSyncStatusInfo.toggle()
    }
    
    func onObjectTap(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func onRelationsListTap(items: [SimpleSearchListItem]) {
        searchData = SimpleSearchData(items: items)
    }
}

extension DateCoordinatorViewModel {
    struct SimpleSearchData: Identifiable {
        let id = UUID()
        let items: [SimpleSearchListItem]
    }
}
