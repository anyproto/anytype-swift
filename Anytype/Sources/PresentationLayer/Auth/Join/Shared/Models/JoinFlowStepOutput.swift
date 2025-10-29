import SwiftUI

@MainActor
protocol JoinFlowStepOutput: JoinBaseOutput {
    func keyPhraseMoreInfo() -> AnyView?
}
