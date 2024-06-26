import SwiftUI

@MainActor
protocol JoinFlowOutput: AnyObject {
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: some JoinFlowStepOutput) -> AnyView
    func keyPhraseMoreInfo() -> AnyView
    
}
