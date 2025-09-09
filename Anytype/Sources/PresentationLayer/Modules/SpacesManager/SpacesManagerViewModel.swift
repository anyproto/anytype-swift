import Foundation
import Combine
import Services
import SwiftUI

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    @Published var participantSpaces: [ParticipantSpaceViewData] = []
    @Published var spaceForCancelRequestAlert: SpaceView?
    @Published var spaceForStopSharingAlert: SpaceView?
    @Published var spaceForLeaveAlert: SpaceView?
    @Published var spaceViewForDelete: SpaceView?
    @Published var spaceCreateData: SpaceCreateData?
    @Published var exportSpaceUrl: URL?
    @Published var showSpaceTypeForCreate = false
    @Published var shouldScanQrCode = false
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceList()
    }
    
    func startWorkspacesTask() async {
        for await participantSpaces in participantSpacesStorage.allParticipantSpacesPublisher.values {
            let participantSpaces = participantSpaces.filter { $0.spaceView.localStatus == .unknown || $0.spaceView.localStatus == .ok }
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
