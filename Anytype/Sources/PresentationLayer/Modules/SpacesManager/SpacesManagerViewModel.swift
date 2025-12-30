import Foundation
import Services
import SwiftUI

@MainActor
@Observable
final class SpacesManagerViewModel {

    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol

    var participantSpaces: [ParticipantSpaceViewData] = []
    var spaceForCancelRequestAlert: SpaceView?
    var spaceForStopSharingAlert: SpaceView?
    var spaceForLeaveAlert: SpaceView?
    var spaceViewForDelete: SpaceView?
    var spaceCreateData: SpaceCreateData?
    var exportSpaceUrl: URL?
    var showSpaceTypeForCreate = false
    var shouldScanQrCode = false
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceList()
    }
    
    func startWorkspacesTask() async {
        for await participantSpaces in participantSpacesStorage.allParticipantSpacesPublisher.values {
            let participantSpaces = participantSpaces.filter {
                $0.spaceView.localStatus == .unknown ||
                $0.spaceView.localStatus == .ok ||
                $0.spaceView.localStatus == .loading
            }
            withAnimation(self.participantSpaces.isEmpty ? nil : .default) {
                self.participantSpaces = participantSpaces.sorted { $0.sortingWeight > $1.sortingWeight }
            }
        }
    }
    
    func onDelete(row: ParticipantSpaceViewData) async throws {
        spaceViewForDelete = row.spaceView
    }
    
    func onLeave(row: ParticipantSpaceViewData) async throws {
        spaceForLeaveAlert = row.spaceView
    }
        
    func onCancelRequest(row: ParticipantSpaceViewData) async throws {
        spaceForCancelRequestAlert = row.spaceView
    }
    
    func onArchive(row: ParticipantSpaceViewData) async throws {
        let tempDir = FileManager.default.createTempDirectory()
        let path = try await workspaceService.workspaceExport(spaceId: row.spaceView.targetSpaceId, path: tempDir.path)
        exportSpaceUrl = URL(fileURLWithPath: path)
    }
    
    func onStopSharing(row: ParticipantSpaceViewData) {
        spaceForStopSharingAlert = row.spaceView
    }
    
    func onTapCreateSpace() {
        showSpaceTypeForCreate.toggle()
    }
    
    func onSelectQrCodeScan() {
        shouldScanQrCode = true
    }
    
    func onSpaceTypeSelected(_ type: SpaceUxType) {
            spaceCreateData = SpaceCreateData(spaceUxType: type)
    }
}

private extension ParticipantSpaceViewData {
    var sortingWeight: Int {
        
        if spaceView.accountStatus == .spaceRemoving {
            return 1
        }
        
        if spaceView.accountStatus == .spaceJoining {
            return 5
        }
        
        if participant?.permission == .owner {
            return 4
        }
        
        if participant?.permission == .writer {
            return 3
        }
        
        if participant?.permission == .reader {
            return 2
        }
        
        return 0
    }
}
