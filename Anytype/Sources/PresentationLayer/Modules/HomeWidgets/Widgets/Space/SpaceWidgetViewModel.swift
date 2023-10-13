import Foundation
import Combine
import Services

@MainActor
final class SpaceWidgetViewModel: ObservableObject {
    
    private enum Constants {
        static let subSpaceId = "SpaceWidgetViewModel-\(UUID().uuidString)"
    }
    
    // MARK: - DI
    
    private let workspaceObjectId: String
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    private let subSpaceId = "SpaceWidgetViewModel-\(UUID().uuidString)"
    
    // MARK: - State
    
    @Published var spaceName: String = ""
    @Published var spaceIcon: Icon?
    @Published var spaceAccessibility: String = ""
    
    init(activeWorkspaceStorage: ActiveWorkpaceStorageProtocol, subscriptionService: SingleObjectSubscriptionServiceProtocol, output: CommonWidgetModuleOutput?) {
        self.workspaceObjectId = activeWorkspaceStorage.workspaceInfo.spaceViewId
        self.subscriptionService = subscriptionService
        self.output = output
        Task {
            await startSubscription()
        }
    }
    
    func onTapWidget() {
        output?.onSpaceSelected()
    }
    
    // MARK: - Private
    
    private func startSubscription() async {
        await subscriptionService.startSubscription(
            subId: Constants.subSpaceId,
            objectId: workspaceObjectId,
            additionalKeys: [.spaceAccessibility]
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceName = details.title
        spaceIcon = details.objectIconImage
        spaceAccessibility = details.spaceAccessibilityValue?.name ?? ""
    }
}
