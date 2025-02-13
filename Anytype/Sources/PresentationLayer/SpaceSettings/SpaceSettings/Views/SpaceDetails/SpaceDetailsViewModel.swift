import SwiftUI
import Services
import AnytypeCore


@MainActor
final class SpaceDetailsViewModel: ObservableObject {
    
    @Published var spaceName = ""
    @Published var spaceDescription = ""
    @Published var spaceIcon: Icon?
    @Published var toastBarData = ToastBarData.empty
    @Published var showIconPickerSpaceId: StringIdentifiable?
    
    private let info: AccountInfo
    private var dataLoaded = false
    
    @Injected(\.participantSpacesStorage)
    private var spacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    init(info: AccountInfo) {
        self.info = info
    }
    
    func setupSubscriptions() async {
        async let participantsSubscription: () = startParticipantsSubscription()
        
        (_) = await (participantsSubscription)
    }
    
    // MARK: - Subscription
    private func startParticipantsSubscription() async {
        for await data in spacesStorage.participantSpaceViewPublisher(spaceId: info.accountSpaceId).values {
            updateViewState(data)
        }
    }
    
    // MARK: - Public
    func onChangeIconTap() {
        showIconPickerSpaceId = info.accountSpaceId.identifiable
    }
    
    func onSaveTap() {
        Task {
            try await workspaceService.workspaceSetDetails(
                spaceId: info.accountSpaceId,
                details: [
                    .name(spaceName),
                    .description(spaceDescription)
                ]
            )
            
            toastBarData = ToastBarData(text: Loc.Settings.updated, showSnackBar: true)
        }
    }

// MARK: - Private

private func updateViewState(_ data: ParticipantSpaceViewData) {
    let spaceView = data.spaceView
    
    spaceIcon = spaceView.objectIconImage
    
    if !dataLoaded {
        spaceName = spaceView.name
        spaceDescription = spaceView.description
        dataLoaded = true
    }
}
}
