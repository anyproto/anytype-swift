import Foundation
import Services

@MainActor
final class StopSharingAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private let spaceId: String
    private let onStopShare: (() -> Void)?
    
    @Published var toast: ToastBarData = .empty
    
    init(spaceId: String, onStopShare: (() -> Void)?) {
        self.spaceId = spaceId
        self.onStopShare = onStopShare
    }
    
    func onTapStopShare() async throws {
        try await workspaceService.stopSharing(spaceId: spaceId)
        toast = ToastBarData(text: Loc.SpaceShare.StopSharing.toast, showSnackBar: true, messageType: .success)
        AnytypeAnalytics.instance().logStopSpaceShare()
        onStopShare?()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenStopShare()
    }
}
