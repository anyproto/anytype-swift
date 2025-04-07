import Combine

@MainActor
final class SpaceLoadingContainerViewModel: ObservableObject {
    
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    
    private let spaceId: String
    
    @Published var showPlaceholder: Bool = true
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func openSpace() async {
        do {
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
            showPlaceholder = false
        } catch {
            // Show error state
        }
    }
    
}
