import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore

@MainActor
final class HomeChatCoordinatorViewModel: ObservableObject {
    
    let spaceInfo: AccountInfo
    var pageNavigation: PageNavigation?
    
    init(spaceInfo: AccountInfo) {
        self.spaceInfo = spaceInfo
    }
}
