import Foundation


@MainActor
final class GallerySpaceSelectionViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    private weak var output: (any GallerySpaceSelectionModuleOutput)?
    
    @Published var spaces: [SpaceView] = []
    
    init(output: (any GallerySpaceSelectionModuleOutput)?) {
        self.output = output
        self.spaces = participantSpacesStorage.activeParticipantSpaces.filter(\.canEdit).map(\.spaceView)
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
