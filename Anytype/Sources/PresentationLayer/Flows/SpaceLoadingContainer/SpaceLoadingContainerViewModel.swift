import Combine
import Services

@MainActor
final class SpaceLoadingContainerViewModel: ObservableObject {
    
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    
    private let spaceId: String
    private var task: Task<Void, Never>?
    
    @Published var info: AccountInfo?
    @Published var errorText: String?
    
    init(spaceId: String) {
        self.spaceId = spaceId
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
