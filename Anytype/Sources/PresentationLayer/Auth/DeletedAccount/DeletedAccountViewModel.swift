import Combine
import UIKit

@MainActor
final class DeletedAccountViewModel: ObservableObject {
    
    @Injected(\.authService)
    private var service: AuthServiceProtocol
    private let deadline: Date
    
    @Injected(\.applicationStateService)
    private var applicationStateService: ApplicationStateServiceProtocol
    
    // MARK: - Initializer
    
    init(deadline: Date) {
        self.deadline = deadline
    }
    
    // MARK: - Internal var
    
    var deletionProgress: CGFloat {
        let daysToDeletion = CGFloat(daysToDeletion)
        let maxDaysDeadline = CGFloat(Constants.maxDaysDeadline)
        let progress: CGFloat = (daysToDeletion / maxDaysDeadline).clamped(0.1, 0.9)
        return 1.0 - progress
    }
    
    var title: String {
        return Loc.daysToDeletionVault(daysToDeletion)
    }
    
    // MARK: - Internal funcs
    
    func logOut() {
        AnytypeAnalytics.instance().logLogout(route: .screenDeletion)
        Task {
            do {
                try await service.logout(removeData: true)
                applicationStateService.state = .auth
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
    
    func cancel() {
        AnytypeAnalytics.instance().logCancelDeletion()
        Task { @MainActor in
            guard let status = try? await service.restoreAccount() else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            if case .active = status {
                applicationStateService.state = .home
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
        }
    }
    
    // MARK: - Private vars
    
    private var daysToDeletion: Int {
        Calendar.current
            .numberOfDaysBetween(Date(), and: deadline)
            .clamped(0, Constants.maxDaysDeadline)
    }
}

// MARK: - Constants

private extension DeletedAccountViewModel {
    
    enum Constants {
        static let maxDaysDeadline: Int = 30
    }
    
}
