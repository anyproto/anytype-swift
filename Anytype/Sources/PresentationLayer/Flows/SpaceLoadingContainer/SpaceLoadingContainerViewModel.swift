import Services
import Foundation

@MainActor
@Observable
final class SpaceLoadingContainerViewModel {

    @ObservationIgnored
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @ObservationIgnored
    private let workspacesStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()

    let spaceId: String
    let showBackground: Bool
    @ObservationIgnored
    private var task: Task<Void, Never>?
    @ObservationIgnored
    private var timeoutTask: Task<Void, any Error>?

    var info: AccountInfo?
    var errorText: String?
    var spaceIcon: Icon?
    
    init(spaceId: String, showBackground: Bool) {
        self.spaceId = spaceId
        self.showBackground = showBackground
        let activeSpaceInfo = activeSpaceManager.workspaceInfo
        if activeSpaceInfo?.accountSpaceId == spaceId {
            info = activeSpaceInfo
        } else {
            // Open space as fast as possible
            openSpace()
        }
    }
    
    func onTryOpenSpaceAgain() {
        guard info.isNil else { return }
        openSpace()
    }
    
    func iconTask() async throws {
        try await Task.sleep(seconds: 1)
        try Task.checkCancellation()
        spaceIcon = workspacesStorage.spaceView(spaceId: spaceId)?.objectIconImage
    }
    
    private func openSpace() {
        task = Task { [activeSpaceManager, weak self, spaceId] in
            self?.errorText = nil
            self?.info = nil
            do {
                self?.info = try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
            } catch {
                self?.errorText = error.localizedDescription
            }
        }
    }
    
    deinit {
        task?.cancel()
        task = nil
    }
}
