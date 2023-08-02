import SwiftUI

@MainActor
protocol JoinFlowOutput: AnyObject {
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: JoinFlowStepOutput) -> AnyView
    
}
