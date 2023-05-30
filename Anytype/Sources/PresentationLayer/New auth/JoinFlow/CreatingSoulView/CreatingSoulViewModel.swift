import SwiftUI

@MainActor
final class CreatingSoulViewModel: ObservableObject {
    
    let state: JoinFlowState
    private weak var output: JoinFlowStepOutput?
    
    init(state: JoinFlowState, output: JoinFlowStepOutput?) {
        self.output = output
        self.state = state
    }
    
    func onFinish() {
        output?.onNext()
    }
}
