import Foundation
import SwiftUI

@MainActor
final class SpaceShareCoordinatorViewModel: ObservableObject {
    
    @Published var showMoreInfo = false
    
    init() {}
    
    func onMoreInfoSelected() {
        showMoreInfo = true
    }
}
