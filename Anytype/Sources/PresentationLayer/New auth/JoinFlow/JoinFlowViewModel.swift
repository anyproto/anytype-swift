import SwiftUI

@MainActor
final class JoinFlowViewModel: ObservableObject, JoinFlowStepOutput {
    
    @Published var step: JoinFlowStep = JoinFlowStep.firstStep
    @Published var showNavigation = true
    @Published var forward = true {
        didSet {
            UIApplication.shared.hideKeyboard()
        }
    }
    @Published var percent: CGFloat = 0
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    @Published var disableBackAction: Bool = false
    
    let progressBarConfiguration = LineProgressBarConfiguration.joinFlow
    
    var counter: String {
        "\(step.rawValue) / \(JoinFlowStep.totalCount)"
    }
    
    private weak var output: JoinFlowOutput?
    private let applicationStateService: ApplicationStateServiceProtocol
    
    init(output: JoinFlowOutput?, applicationStateService: ApplicationStateServiceProtocol) {
        self.output = output
        self.applicationStateService = applicationStateService
        
        updatePercent(step)
    }
    
    @ViewBuilder
    func content() -> some View {
        output?.onStepChanged(step, output: self)
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
            showNavigation = !nextStep.isLast
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
    
    func onError(_ error: Error) {
        errorText = error.localizedDescription
    }
    
    func disableBackAction(_ disable: Bool) {
        disableBackAction = disable
    }
    
    private func updatePercent(_ step: JoinFlowStep) {
        percent = CGFloat(step.rawValue) / CGFloat(JoinFlowStep.totalCount)
    }
    
    private func finishFlow() {
        applicationStateService.state = .home
    }
}
