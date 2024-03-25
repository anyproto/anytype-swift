import Foundation
import Combine
import Services
import SwiftUI

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: ParticipantSpacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    @Published var participantSpaces: [ParticipantSpaceView] = []
    @Published var spaceForCancelRequestAlert: SpaceView?
    @Published var spaceForStopSharingAlert: SpaceView?
    @Published var spaceForLeaveAlert: SpaceView?
    @Published var spaceViewForDelete: SpaceView?
        
    func startWorkspacesTask() async {
        for await participantSpaces in participantSpacesStorage.allParticipantSpacesPublisher.values {
            withAnimation(self.participantSpaces.isEmpty ? nil : .default) {
                self.participantSpaces = participantSpaces
            }
        }
    }
    
    func onDelete(row: ParticipantSpaceView) async throws {
        spaceViewForDelete = row.spaceView
    }
    
    func onLeave(row: ParticipantSpaceView) async throws {
        spaceForLeaveAlert = row.spaceView
    }
        
    func onCancelRequest(row: ParticipantSpaceView) async throws {
        spaceForCancelRequestAlert = row.spaceView
    }
    
    func onArchive(row: ParticipantSpaceView) async throws {
        // TODO: Implement it
    }
    
    func onStopSharing(row: ParticipantSpaceView) {
        spaceForStopSharingAlert = row.spaceView
    }
}
