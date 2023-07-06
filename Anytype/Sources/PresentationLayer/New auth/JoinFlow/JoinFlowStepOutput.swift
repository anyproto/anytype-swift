import SwiftUI

@MainActor
protocol JoinFlowStepOutput: AnyObject {
    
    func onNext()
    func onBack()
    func onError(_ error: Error)
}
