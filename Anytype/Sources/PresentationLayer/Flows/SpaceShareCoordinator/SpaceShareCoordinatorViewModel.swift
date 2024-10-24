import Foundation
import SwiftUI
import Services

@MainActor
final class SpaceShareCoordinatorViewModel: ObservableObject {
    
    @Published var showMoreInfo = false
    let workspaceInfo: AccountInfo
    
    init(workspaceInfo: AccountInfo) {
        self.workspaceInfo = workspaceInfo
    }
    
    func onMoreInfoSelected() {
        showMoreInfo = true
    }
}
