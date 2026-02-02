import Foundation


@MainActor
@Observable
final class GallerySpaceSelectionViewModel {

    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private weak var output: (any GallerySpaceSelectionModuleOutput)?

    var spaces: [SpaceView] = []
    
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
