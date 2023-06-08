import SwiftUI

@MainActor
protocol JoinFlowOutput: AnyObject {
    
    func onStepChanged(_ step: JoinFlowStep, output: JoinFlowStepOutput) -> AnyView
    
}
