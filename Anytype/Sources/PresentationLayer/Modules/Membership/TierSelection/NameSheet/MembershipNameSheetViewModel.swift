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
    
    @Injected(\.nameService)
    private var nameService: NameServiceProtocol
    
    private let tier: MembershipTier
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
            try await Task.sleep(seconds: 0.5)
            try Task.checkCancellation()
            
            do {
                try await nameService.resolveName(name: name)
                state = .validated
            } catch let error {
                state = .error(text: error.localizedDescription)
            }
        }
    }
}
