import SwiftUI
import Services

@MainActor
final class EmailVerificationViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var error = ""
    @Published var loading = false
    @Published var timeRemaining = 60
    
    var number1: String { text.letterAtIndex(0) }
    var number2: String { text.letterAtIndex(1) }
    var number3: String { text.letterAtIndex(2) }
    var number4: String { text.letterAtIndex(3) }
    
    
    private let data: EmailVerificationData
    private let membershipService: MembershipServiceProtocol
    private let onSuccessfulValidation: () -> ()
    
    init(
        data: EmailVerificationData,
        membershipService: MembershipServiceProtocol,
        onSuccessfulValidation: @escaping () -> ()
    ) {
        self.data = data
        self.membershipService = membershipService
        self.onSuccessfulValidation = onSuccessfulValidation
    }
    
    func onTextChange() {
        let filteredText = String(text.filter { $0.isWholeNumber }.prefix(4))
        
        guard text == filteredText else {
            text = filteredText
            return
        }
        
        if text.count == 4 {
            asyncAction {
                try await self.membershipService.verifyEmailCode(code: self.text)
                self.onSuccessfulValidation()
            }
        }
    }
    
    func resendEmail() {
        asyncAction {
            try await self.membershipService.getVerificationEmail(data: self.data)
            self.timeRemaining = 60
        }
    }
    
    private func asyncAction(action: @escaping () async throws -> ()) {
        loading = true
        error = ""
        
        Task {
            defer { loading = false }
            
            do {
                try await action()
            } catch let error {
                self.error = error.localizedDescription
            }
        }
    }
}

fileprivate extension String {
    func letterAtIndex(_ index: Int) -> String {
        guard self.count >= index + 1 else {
            return ""
        }
        return String(Array(self)[index])
    }
}
