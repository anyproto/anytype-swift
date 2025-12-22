import Foundation
import SwiftUI

@MainActor
@Observable
final class JoinCoordinatorViewModel {

    @ObservationIgnored
    let state: JoinFlowState

    init(state: JoinFlowState) {
        self.state = state
    }
}
