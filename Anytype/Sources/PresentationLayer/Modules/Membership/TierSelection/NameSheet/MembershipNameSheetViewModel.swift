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
    
    @Injected(\.nameService)
    private var nameService: NameServiceProtocol
    
    private let tier: MembershipTier
    
    private var validationTask: Task<(), any Error>?
    
    init(tier: MembershipTier) {
        self.tier = tier
    }
    
    func validateName(name: String) {
        state = .default

        switch tier {
        case .explorer, .custom:
            return
        case .builder:
            if name.count >= 7 {
                resolveName(name: name)
            }
        case .coCreator:
            if name.count >= 5 {
                resolveName(name: name)
            }
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
