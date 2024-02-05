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
    
    func onTapSpace(spaceView: SpaceView) {
        output?.onSelectSpace(result: .space(spaceId: spaceView.targetSpaceId))
    }
    
    func onTapNewSpace() {
        output?.onSelectSpace(result: .newSpace)
    }
}
