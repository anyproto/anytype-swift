import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        JoinFlowView(output: self).eraseToAnyView()
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: JoinFlowStepOutput) -> AnyView {
        switch step {
        case .soul:
            return SoulView(state: state, output: output).eraseToAnyView()
        case .key:
            return KeyPhraseView(state: state, output: output).eraseToAnyView()
        }
    }
    
    func keyPhraseMoreInfo() -> AnyView {
        KeyPhraseMoreInfoView().eraseToAnyView()
    }
}
