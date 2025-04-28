import Foundation
import Services

@MainActor
final class StopSharingAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    private let spaceId: String
    private let onStopShare: (() -> Void)?
    
    @Published var toast: ToastBarData?
    
    init(spaceId: String, onStopShare: (() -> Void)?) {
        self.spaceId = spaceId
        self.onStopShare = onStopShare
    }
    
    func onTapStopShare() async throws {
        try await workspaceService.stopSharing(spaceId: spaceId)
        toast = ToastBarData(Loc.SpaceShare.StopSharing.toast, type: .success)
        AnytypeAnalytics.instance().logStopSpaceShare()
        onStopShare?()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenStopShare()
    }
}
