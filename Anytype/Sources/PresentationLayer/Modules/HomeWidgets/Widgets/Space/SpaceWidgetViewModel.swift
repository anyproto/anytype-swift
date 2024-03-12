import Foundation
import Combine
import Services

@MainActor
final class SpaceWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: SingleObjectSubscriptionServiceProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subSpaceId = "SpaceWidgetViewModel-\(UUID().uuidString)"
    private let onSpaceSelected: () -> Void
    
    // MARK: - State
    
    @Published var spaceName: String = ""
    @Published var spaceIcon: Icon?
    @Published var spaceAccessType: String = ""
    
    init(onSpaceSelected: @escaping () -> Void) {
        self.onSpaceSelected = onSpaceSelected
        Task {
            await startSubscription()
        }
    }
    
    // MARK: - Private
    
    private func startSubscription() async {
        await subscriptionService.startSubscription(
            subId: subSpaceId,
            objectId: activeWorkspaceStorage.workspaceInfo.spaceViewId,
            additionalKeys: SpaceView.subscriptionKeys
        ) { [weak self] details in
            self?.handleSpaceDetails(details: SpaceView(details: details))
        }
    }
    
    func onTapWidget() {
        onSpaceSelected()
    }
    
    private func handleSpaceDetails(details: SpaceView) {
        spaceName = details.title
        spaceIcon = details.objectIconImage
        spaceAccessType = details.spaceAccessType?.name ?? ""
    }
}
