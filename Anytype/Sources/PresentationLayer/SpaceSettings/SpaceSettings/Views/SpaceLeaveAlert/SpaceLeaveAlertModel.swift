import Foundation
import Services

@MainActor
@Observable
final class SpaceLeaveAlertModel {

    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol

    @ObservationIgnored
    private let spaceId: String

    var spaceName: String = ""
    var toast: ToastBarData?
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.spaceName = workspaceStorage.spaceView(spaceId: spaceId)?.title ?? ""
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenLeaveSpace()
    }
    
    func onTapLeave() async throws {
        AnytypeAnalytics.instance().logLeaveSpace()
        try await workspaceService.deleteSpace(spaceId: spaceId)
        toast = ToastBarData(Loc.SpaceSettings.LeaveAlert.toast(spaceName), type: .success)
    }
}
