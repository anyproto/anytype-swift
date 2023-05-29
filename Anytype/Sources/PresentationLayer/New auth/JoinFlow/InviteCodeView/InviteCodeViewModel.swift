import SwiftUI

@MainActor
final class InviteCodeViewModel: ObservableObject {
    
    @Published var inviteCode = ""
    
    private weak var output: JoinFlowStepOutput?
    
    init(output: JoinFlowStepOutput?) {
        self.output = output
    }
    
    func onNextButtonTap() {
        UIApplication.shared.hideKeyboard()
        output?.onNext()
    }
}
