import Combine
import Services

@MainActor
final class SpaceLoadingContainerViewModel: ObservableObject {
    
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    private let workspacesStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    
    let spaceId: String
    let showBackground: Bool
    let spaceIcon: Icon?
    private var task: Task<Void, Never>?
    
    @Published var info: AccountInfo?
    @Published var errorText: String?
    
    init(spaceId: String, showBackground: Bool) {
        self.spaceId = spaceId
        self.showBackground = showBackground
        self.spaceIcon = workspacesStorage.spaceView(spaceId: spaceId)?.objectIconImage
        // Open space as fast as possible
        openSpace()
    }
    
    func onTryOpenSpaceAgain() {
        openSpace()
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
