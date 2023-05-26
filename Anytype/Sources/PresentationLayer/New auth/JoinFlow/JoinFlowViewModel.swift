import SwiftUI

@MainActor
final class JoinFlowViewModel: ObservableObject, JoinFlowStepOutput {
    
    @Published var step: JoinFlowStep = JoinFlowStep.firstStep
    @Published var forward = true {
        didSet {
            UIApplication.shared.hideKeyboard()
        }
    }
    @Published var percent: CGFloat = 0
    
    let progressBarConfiguration = LineProgressBarConfiguration.joinFlow
    
    var counter: String {
        "\(step.rawValue) / \(JoinFlowStep.allCases.count)"
    }
    
    private let state = JoinFlowState()
    private weak var output: JoinFlowOutput?
    private let applicationStateService: ApplicationStateServiceProtocol
    
    init(output: JoinFlowOutput?, applicationStateService: ApplicationStateServiceProtocol) {
        self.output = output
        self.applicationStateService = applicationStateService
        
        updatePercent(step)
    }
    
    @ViewBuilder
    func content() -> some View {
        output?.onStepChanged(step, state: state, output: self)
    }
    
    // MARK: - JoinStepOutput
    
    func onNext() {
        guard let nextStep = step.next else {
            finishFlow()
            return
        }
        forward = true
        
        withAnimation {
            updatePercent(nextStep)
            step = nextStep
        }
    }
    
    func onBack() {
        guard let previousStep = step.previous else { return }
        forward = false
        
        withAnimation {
            updatePercent(previousStep)
            step = previousStep
        }
    }
    
    private func updatePercent(_ step: JoinFlowStep) {
        percent = CGFloat(step.rawValue) / CGFloat(JoinFlowStep.allCases.count)
    }
    
    private func finishFlow() {
        applicationStateService.state = .home
    }
}
