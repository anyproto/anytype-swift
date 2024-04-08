import Services
import SwiftUI
import AnytypeCore


enum MembershipNameSheetViewState {
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

enum MembershipAnyNameAvailability {
    case notAvailable
    case availableForPruchase
    case alreadyBought
}


@MainActor
final class MembershipNameSheetViewModel: ObservableObject {
    @Published var state = MembershipNameSheetViewState.default
    let tier: MembershipTier
    let anyName: String
    
    var anyNameAvailability: MembershipAnyNameAvailability {
        switch tier.anyName {
        case .none:
            .notAvailable
        case .some:
            if anyName.isEmpty {
                .availableForPruchase
            } else {
                .alreadyBought
            }
        }
    }
    
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
    private var memberhsipService: MembershipServiceProtocol
    
    private var validationTask: Task<(), any Error>?
    
    init(tier: MembershipTier, anyName: String) {
        self.tier = tier
        self.anyName = anyName
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
            try await Task.sleep(seconds: 0.5)
            try Task.checkCancellation()
            
            do {
                try await memberhsipService.validateName(name: "\(name).any", tierType: tier.type)
                state = .validated
            } catch let error as MembershipServiceProtocol.ValidateNameError {
                state = .error(text: error.validateNameSheetError)
            } catch let error {
                state = .error(text: error.localizedDescription)
            }
        }
    }
}
