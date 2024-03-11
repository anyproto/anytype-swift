import Foundation


@MainActor
final class GallerySpaceSelectionViewModel: ObservableObject {
    
    private let workspaceStorage: WorkspacesStorageProtocol
    private weak var output: GallerySpaceSelectionModuleOutput?
    
    @Published var spaces: [SpaceView]
    @Published var canCreateNewSpace: Bool
    
    init(workspaceStorage: WorkspacesStorageProtocol, output: GallerySpaceSelectionModuleOutput?) {
        self.workspaceStorage = workspaceStorage
        self.output = output
        self.spaces = workspaceStorage.workspaces
        self.canCreateNewSpace = workspaceStorage.canCreateNewSpace()
    }
    
    func onTapSpace(spaceView: SpaceView) {
        AnytypeAnalytics.instance().logClickGalleryInstallSpace(type: .existing)
        output?.onSelectSpace(result: .space(spaceId: spaceView.targetSpaceId))
    }
    
    func onTapNewSpace() {
        AnytypeAnalytics.instance().logClickGalleryInstallSpace(type: .new)
        output?.onSelectSpace(result: .newSpace)
    }
}
