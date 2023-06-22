import SwiftUI
import Combine
import AnytypeCore

@MainActor
final class EnteringVoidViewModel: ObservableObject {
    
    @Published var dismiss: Bool = false
    
    private weak var output: LoginFlowOutput?
    private let applicationStateService: ApplicationStateServiceProtocol
    private let authService: AuthServiceProtocol
    private let metricsService: MetricsServiceProtocol
    private let accountEventHandler: AccountEventHandlerProtocol
    
    private var cancellable: AnyCancellable?
    
    init(
        output: LoginFlowOutput?,
        applicationStateService: ApplicationStateServiceProtocol,
        authService: AuthServiceProtocol,
        metricsService: MetricsServiceProtocol,
        accountEventHandler: AccountEventHandlerProtocol
    ) {
        self.output = output
        self.applicationStateService = applicationStateService
        self.authService = authService
        self.metricsService = metricsService
        self.accountEventHandler = accountEventHandler
        handleAccountShowEvent()
    }
    
    func onAppear() {
        authService.accountRecoverAsync { [weak self] error in
            guard let self, error != nil else { return }
            self.dismiss.toggle()
        }
    }
    
    private func handleAccountShowEvent() {
        cancellable = accountEventHandler.accountShowPublisher
            .sink { [weak self] accountId in
                self?.selectProfile(id: accountId)
            }
    }
    
    private func selectProfile(id: String) {
        Task {
            do {
                try await metricsService.metricsSetParameters()
                let status = try await authService.selectAccount(id: id)
                
                switch status {
                case .active:
                    applicationStateService.state = .home
                case .pendingDeletion:
                    applicationStateService.state = .delete
                case .deleted:
                    dismiss.toggle()
                }
            } catch SelectAccountError.failedToFindAccountInfo {
                if FeatureFlags.migrationGuide {
                    output?.onShowMigrationGuideAction()
                }
                dismiss.toggle()
            } catch {
                dismiss.toggle()
            }
        }
    }
}
