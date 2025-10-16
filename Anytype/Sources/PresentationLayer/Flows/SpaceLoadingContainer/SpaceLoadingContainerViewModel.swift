import Combine
import Services
import Foundation

@MainActor
final class SpaceLoadingContainerViewModel: ObservableObject {
    
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    private let workspacesStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    
    let spaceId: String
    let showBackground: Bool
    private var task: Task<Void, Never>?
    private var timeoutTask: Task<Void, any Error>?
    
    @Published var info: AccountInfo?
    @Published var errorText: String?
    @Published var spaceIcon: Icon?
    
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
