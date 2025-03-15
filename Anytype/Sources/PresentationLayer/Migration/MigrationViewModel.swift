import Foundation
@preconcurrency import Combine
import Services

struct MigrationModuleData: Identifiable {
    let id: String
    let onFinish: () async -> Void
}

enum MigrationState: Equatable {
    case initial
    case progress
    case error(title: String, message: String)
}

@MainActor
final class MigrationViewModel: ObservableObject {
    
    private let data: MigrationModuleData
    private var activeProcess: Process?
    
    @Published var progress: CGFloat = 0
    @Published var startFlowId: String?
    @Published var dismiss = false
    @Published var state = MigrationState.initial
    
    @Injected(\.accountMigrationService)
    private var accountMigrationService: any AccountMigrationServiceProtocol
    @Injected(\.localRepoService)
    private var localRepoService: any LocalRepoServiceProtocol
    @Injected(\.processSubscriptionService)
    private var processSubscriptionService: any ProcessSubscriptionServiceProtocol
    
    private weak var output: (any MigrationModuleOutput)?
    private var processSubscription: AnyCancellable?
    
    // MARK: - Initializer
    
    init(data: MigrationModuleData, output: (any MigrationModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    func startFlow() async {
        async let processSubscription: () = subscribeOnProcess()
        async let migration: () = startMigration()
        (_, _) = await (processSubscription, migration)
    }
    
    func startUpdate() {
        clearProcessData()
        state = .progress
        startFlowId = UUID().uuidString
    }
    
    func readMore() {
        output?.onReadMoreTap()
    }
    
    func onDebugTap() {
        output?.onDebugTap()
    }
    
    private func subscribeOnProcess() async {
        processSubscription?.cancel()
        processSubscription = await processSubscriptionService.addHandler { [weak self] events in
            await self?.handleProcesses(events: events)
        }
    }
    
    private func startMigration() async {
        do {
            try await accountMigrationService.accountMigrate(id: data.id, rootPath: localRepoService.middlewareRepoPath)
            dismiss.toggle()
            await data.onFinish()
        } catch is CancellationError {
            // Ignore cancellations
        } catch AccountMigrationError.notEnoughFreeSpace {
            state = .error(
                title: Loc.Migration.Error.NotEnoughtSpace.title,
                message: Loc.Migration.Error.NotEnoughtSpace.message
            )
        } catch {
            state = .error(
                title: Loc.error,
                message: Loc.unknownError
            )
        }
    }
    
    func tryAgainTapped() {
        startUpdate()
    }
    
    private func clearProcessData() {
        activeProcess = nil
        progress = 0
    }
    
    private func handleProcesses(events: [ProcessEvent]) {
        for event in events {
            switch event {
            case .new(let process):
                guard activeProcess.isNil else { return }
                activeProcess = process
                updateProgress(with: process)
            case .update(let process):
                guard process.id == activeProcess?.id else { return }
                activeProcess = process
                updateProgress(with: process)
            case .done(let process):
                guard process.id == activeProcess?.id else { return }
                activeProcess = nil
                updateProgress(with: process)
            }
        }
    }
    
    private func updateProgress(with process: Process) {
        progress = CGFloat(process.progress.done) / CGFloat(process.progress.total)
    }
}
