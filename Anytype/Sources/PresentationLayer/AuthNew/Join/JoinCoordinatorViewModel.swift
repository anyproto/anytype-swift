import Foundation
import SwiftUI

@MainActor
final class JoinCoordinatorViewModel: ObservableObject {
    
    let state: JoinFlowState
    
    init(state: JoinFlowState) {
        self.state = state
    }
}
