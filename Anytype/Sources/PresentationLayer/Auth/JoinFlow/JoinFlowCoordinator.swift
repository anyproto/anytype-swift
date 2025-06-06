import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow(state: JoinFlowState) -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow(state: JoinFlowState) -> AnyView {
        JoinFlowView(state: state, output: self).eraseToAnyView()
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: some JoinFlowStepOutput) -> AnyView {
        switch step {
        case .key:
            KeyPhraseView(state: state, output: output).eraseToAnyView()
        case .soul:
            SoulView(state: state, output: output).eraseToAnyView()
        case .email:
            EmailCollectionView(state: state, output: output).eraseToAnyView()
        }
    }
    
    func keyPhraseMoreInfo() -> AnyView {
        KeyPhraseMoreInfoView().eraseToAnyView()
    }
}
