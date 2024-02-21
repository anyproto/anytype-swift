import Foundation
import Combine

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    private let workspacesStorage: WorkspacesStorageProtocol
    
    @Published var spaces: [SpaceView] = []
    
    init(workspacesStorage: WorkspacesStorageProtocol) {
        self.workspacesStorage = workspacesStorage
    }
    
    func startWorkspacesTask() async {
        for await spaces in workspacesStorage.workspsacesPublisher.values {
            updateWorkspaces(spaces: spaces)
            print("update handle")
        }
    }
    
    private func updateWorkspaces(spaces: [SpaceView]) {
        self.spaces = spaces
    }
}
