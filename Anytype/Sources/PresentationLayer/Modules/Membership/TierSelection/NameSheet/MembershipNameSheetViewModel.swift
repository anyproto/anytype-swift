import Services
import SwiftUI

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


@MainActor
final class MembershipNameSheetViewModel: ObservableObject {
    @Published var state = MembershipNameSheetViewState.default
    let anyName: String
    
    // TODO: use middleware api
    var minimumNumberOfCharacters: Int {
        switch tier {
        case .builder:
            7
        case .coCreator:
            5
        case .explorer, .custom:
            .max
        }
    }
    
    @Injected(\.membershipService)
    private var memberhsipService: MembershipServiceProtocol
    
    private let tier: MembershipTier
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
                try await memberhsipService.validateName(name: "\(name).any", tier: tier)
                state = .validated
            } catch let error as MembershipServiceProtocol.ValidateNameError {
                state = .error(text: error.validateNameSheetError)
            } catch let error {
                state = .error(text: error.localizedDescription)
            }
        }
    }
}
