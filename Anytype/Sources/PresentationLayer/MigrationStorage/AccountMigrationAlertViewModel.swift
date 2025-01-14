import SwiftUI
import Services

struct AccountMigrationData: Identifiable {
    let accountId: String
    let completion: ((any Error)?) -> Void
    
    var id: String { accountId }
}

@MainActor
final class AccountMigrationAlertViewModel: ObservableObject {
    
    private let accountMigrationService: any AccountMigrationServiceProtocol = Container.shared.accountMigrationService()
    private let localRepoService: any LocalRepoServiceProtocol = Container.shared.localRepoService()
    
    private let accountId: String
    private let completion: ((any Error)?) -> Void
    
    @Published var dismiss = false
    
    init(data: AccountMigrationData) {
        self.accountId = data.accountId
        self.completion = data.completion
    }
    
    func startMigration() async {
        defer {
            dismiss = true
        }
        do {
            try await accountMigrationService.accountMigrate(id: accountId, rootPath: localRepoService.middlewareRepoPath)
            completion(nil)            
        } catch {
            completion(error)
        }
    }
    
    func onCancelTap() {
        Task {
            defer {
                dismiss = true
            }
            do {
                try await accountMigrationService.accountMigrateCancel(id: accountId)
            } catch {
                completion(error)
            }
        }
    }
}
