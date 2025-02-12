import Foundation
import SwiftUI
import Services

@MainActor
final class SpaceShareCoordinatorViewModel: ObservableObject {
    
    @Published var showMoreInfo = false
    let data: SpaceShareData
    
    init(data: SpaceShareData) {
        self.data = data
    }
    
    func onMoreInfoSelected() {
        showMoreInfo = true
    }
}
