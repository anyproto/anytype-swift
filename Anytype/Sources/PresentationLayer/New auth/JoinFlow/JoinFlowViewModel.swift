import SwiftUI

@MainActor
final class JoinFlowViewModel: ObservableObject, JoinFlowStepOutput {
    
    @Published var step: JoinFlowStep = JoinFlowStep.firstStep
    @Published var forward = true
    
    var counter: String {
        "\(step.rawValue) / \(JoinFlowStep.allCases.count)"
    }
    
    private weak var output: JoinFlowOutput?
    
    init(output: JoinFlowOutput?) {
        self.output = output
    }
    
    @ViewBuilder
    func content() -> some View {
        output?.onStepChanged(step, output: self)
    }
    
    // MARK: - JoinStepOutput
    
    func onNext() {
        guard let nextStep = step.next else { return }
        forward = true
        
        withAnimation {
            step = nextStep
        }
    }
    
    func onBack() {
        guard let previousStep = step.previous else { return }
        forward = false
        
        withAnimation {
            step = previousStep
        }
    }
    
}
