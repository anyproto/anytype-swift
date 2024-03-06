import SwiftUI
import Services

@MainActor
final class EmailVerificationViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var error = ""
    @Published var validating = false
    
    var number1: String { text.letterAtIndex(0) }
    var number2: String { text.letterAtIndex(1) }
    var number3: String { text.letterAtIndex(2) }
    var number4: String { text.letterAtIndex(3) }
    
    private let membershipService: MembershipServiceProtocol
    private let onSuccessfulValidation: () -> ()
    
    init(
        membershipService: MembershipServiceProtocol,
        onSuccessfulValidation: @escaping () -> ()
    ) {
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
            validating = true
            error = ""
            
            Task {
                defer { validating = false }
                
                do {
                    try await membershipService.verifyEmailCode(code: text)
                    onSuccessfulValidation()
                } catch let error {
                    self.error = error.localizedDescription
                }
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
