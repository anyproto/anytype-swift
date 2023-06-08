import SwiftUI

@MainActor
protocol JoinFlowStepOutput: AnyObject {
    
    func onNext()
    func onBack()
    
}
