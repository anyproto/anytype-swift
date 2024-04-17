import SwiftUI

@MainActor
protocol JoinFlowStepOutput: AnyObject {
    
    func onNext()
    func onBack()
    func onError(_ error: Error)
    func disableBackAction(_ disable: Bool)
    func keyPhraseMoreInfo() -> AnyView?
    
}
