import SwiftUI
import Services
import AnytypeCore


enum MembershipNameValidationViewState: Equatable {
    case `default`
    case validating
    case error(text: String)
    case validated
    
    var isValidated: Bool {
        if case .validated = self {
            return true
        } else {
            return false
        }
    }
}

@MainActor
final class MembershipNameValidationViewModel: ObservableObject {
    @Published var state = MembershipNameValidationViewState.default
    let tier: MembershipTier
    
    var minimumNumberOfCharacters: UInt32 {
        switch tier.anyName {
        case .none:
            anytypeAssertionFailure("Unsupported tier for name selection \(tier)")
            return .max
        case .some(let minLenght):
            return minLenght
        }
    }
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    private var validationTask: Task<(), any Error>?
    
    init(tier: MembershipTier) {
        self.tier = tier
    }
    
    func validateName(name: String) {
        state = .default
        
        if name.count >= minimumNumberOfCharacters {
            resolveName(name: name)
        }
    }
    
    private func resolveName(name: String) {
        validationTask?.cancel()
        state = .validating
        
        validationTask = Task {
            try await Task.sleep(seconds: 0.3)
            try Task.checkCancellation()
            
            do {
                try await membershipService.validateName(name: name, tierType: tier.type)
                state = .validated
            } catch let error {
                state = .error(text: error.localizedDescription)
            }
        }
    }
}
