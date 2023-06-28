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
    
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    
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
        Task {
            do {
                try await authService.accountRecover()
            } catch {
                errorText = error.localizedDescription
            }
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
                    errorText = Loc.accountDeleted
                }
            } catch SelectAccountError.failedToFindAccountInfo {
                if FeatureFlags.migrationGuide {
                    dismiss.toggle()
                    output?.onShowMigrationGuideAction()
                } else {
                    errorText = Loc.selectAccountError
                }
            } catch SelectAccountError.accountIsDeleted {
                errorText = Loc.accountDeleted
            } catch SelectAccountError.failedToFetchRemoteNodeHasIncompatibleProtoVersion {
                errorText = Loc.Account.Select.Incompatible.Version.Error.text
            } catch {
                errorText = Loc.selectAccountError
            }
        }
    }
}
