import SwiftUI
import Combine
import AnytypeCore

@MainActor
final class EnteringVoidViewModel: ObservableObject {
    
    @Published var dismiss: Bool = false
    
    private weak var output: LoginFlowOutput?
    private let applicationStateService: ApplicationStateServiceProtocol
    private let authService: AuthServiceProtocol
    private let accountEventHandler: AccountEventHandlerProtocol
    
    private var cancellable: AnyCancellable?
    
    private var delayTask: Task<(), Error>?
    
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
        accountEventHandler: AccountEventHandlerProtocol
    ) {
        self.output = output
        self.applicationStateService = applicationStateService
        self.authService = authService
        self.accountEventHandler = accountEventHandler
        handleAccountShowEvent()
    }
    
    func onAppear() {
        startDelayTask()
        Task {
            do {
                try await authService.accountRecover()
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
    
    private func startDelayTask() {
        delayTask = Task {
            // add delay to avoid screen blinking
            try await Task.sleep(seconds: 1.5)
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
                let status = try await authService.selectAccount(id: id)
                
                switch status {
                case .active:
                    _ = await delayTask?.result
                    applicationStateService.state = .home
                case .pendingDeletion:
                    _ = await delayTask?.result
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
