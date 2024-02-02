import Foundation


@MainActor
final class GallerySpaceSelectionViewModel: ObservableObject {
    
    private let workspaceStorage: WorkspacesStorageProtocol
    private weak var output: GallerySpaceSelectionModuleOutput?
    
    @Published var spaces: [SpaceView]
    
    init(workspaceStorage: WorkspacesStorageProtocol, output: GallerySpaceSelectionModuleOutput?) {
        self.workspaceStorage = workspaceStorage
        self.output = output
        self.spaces = workspaceStorage.workspaces
    }
}
