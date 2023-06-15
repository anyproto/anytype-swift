import SwiftUI
import Combine
import AnytypeCore

@MainActor
final class SelectProfileViewModel: ObservableObject {
    
    @Published var showError: Bool = false
    var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    
    @Published var snackBarData = ToastBarData.empty
    
    private let authService = ServiceLocator.shared.authService()
    private let fileService = ServiceLocator.shared.fileService()
    private let metricsService = ServiceLocator.shared.metricsService()
    private let accountEventHandler = ServiceLocator.shared.accountEventHandler()
    
    private var cancellable: AnyCancellable?
    
    private var isAccountRecovering = false
    
    private let applicationStateService: ApplicationStateServiceProtocol
    private let onShowMigrationGuide: () -> Void
    
    init(applicationStateService: ApplicationStateServiceProtocol, onShowMigrationGuide: @escaping () -> Void) {
        self.applicationStateService = applicationStateService
        self.onShowMigrationGuide = onShowMigrationGuide
    }
    
    func onAppear() {
        handleAccountShowEvent()
        
        isAccountRecovering = true
        authService.accountRecover { [weak self] error in
            guard let self = self, let error = error else { return }
            
            self.isAccountRecovering = false
            self.errorText = error.localizedDescription
            self.snackBarData = .empty
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.isAccountRecovering else { return }
            
            self.snackBarData = .init(text: Loc.settingUpEncryptedStoragePleaseWait, showSnackBar: true)
        }
    }
    
}

// MARK: - Private func

private extension SelectProfileViewModel {
    
    func handleAccountShowEvent() {
        cancellable = accountEventHandler.accountShowPublisher
            .sink { [weak self] accountId in
                self?.selectProfile(id: accountId)
            }
    }
    
    func selectProfile(id: String) {
        Task { @MainActor in
            do {
                try await metricsService.metricsSetParameters()
                let status = try await authService.selectAccount(id: id)
                isAccountRecovering = false
                snackBarData = .empty
                
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
                    onShowMigrationGuide()
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
