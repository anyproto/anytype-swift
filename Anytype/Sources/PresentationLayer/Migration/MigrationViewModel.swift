import Foundation
import Combine
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
@Observable
final class MigrationViewModel {

    @ObservationIgnored
    private let data: MigrationModuleData
    @ObservationIgnored
    private var activeProcess: Process?

    var progress: CGFloat = 0
    var startFlowId: String?
    var dismiss = false
    var state = MigrationState.initial

    @ObservationIgnored @Injected(\.accountMigrationService)
    private var accountMigrationService: any AccountMigrationServiceProtocol
    @ObservationIgnored @Injected(\.localRepoService)
    private var localRepoService: any LocalRepoServiceProtocol
    @ObservationIgnored @Injected(\.processSubscriptionService)
    private var processSubscriptionService: any ProcessSubscriptionServiceProtocol

    @ObservationIgnored
    private weak var output: (any MigrationModuleOutput)?
    @ObservationIgnored
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
        } catch let AccountMigrationError.notEnoughFreeSpace(requaredSpace) {
            let size = ByteCountFormatter.fileFormatter.string(fromByteCount: requaredSpace)
            state = .error(
                title: Loc.Migration.Error.NotEnoughtSpace.title,
                message: Loc.Migration.Error.NotEnoughtSpace.message(size)
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
