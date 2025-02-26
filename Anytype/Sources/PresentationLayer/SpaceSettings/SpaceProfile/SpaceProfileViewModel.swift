import SwiftUI
import Services
import AnytypeCore


@MainActor
final class SpaceProfileViewModel: ObservableObject {
    @Published var spaceName = ""
    @Published var spaceDescription = ""
    @Published var spaceIcon: Icon?
    
    @Published var allowDelete = false
    @Published var allowLeave = false
    
    @Published var showInfoView = false
    @Published var showSpaceDeleteAlert = false
    @Published var showSpaceLeaveAlert = false
    
    @Published var settingsInfo = [SettingsInfoModel]()
    @Published var snackBarData = ToastBarData.empty
    
    let workspaceInfo: AccountInfo
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.spaceSettingsInfoBuilder)
    private var spaceSettingsInfoBuilder: any SpaceSettingsInfoBuilderProtocol
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(workspaceInfo.accountSpaceId)
    
    private var owner: Participant?
    private var spaceView: SpaceView?
    
    init(info: AccountInfo) {
        self.workspaceInfo = info
    }
    
    func setupSubscriptions() async {
        async let participantTask: () = startParticipantTask()
        async let ownerTask: () = startOwnerTask()
        
        (_) = await (participantTask, ownerTask)
    }
    
    func onInfoTap() {
        showInfoView.toggle()
    }
    
    func onDeleteTap() {
        AnytypeAnalytics.instance().logClickDeleteSpace(route: .settings)
        showSpaceDeleteAlert.toggle()
    }
    
    func onLeaveTap() {
        showSpaceLeaveAlert.toggle()
    }
    
    // MARK: - Private
    
    private func startParticipantTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: workspaceInfo.accountSpaceId).values {
            spaceView = participantSpaceView.spaceView
            
            spaceIcon = participantSpaceView.spaceView.objectIconImage
            spaceName = participantSpaceView.spaceView.name
            spaceDescription = participantSpaceView.spaceView.description
            
            allowDelete = participantSpaceView.canBeDeleted
            allowLeave = participantSpaceView.canLeave
            
            updateSettingsInfo()
        }
    }
    
    
    private func startOwnerTask() async {
        for await participants in participantsSubscription.participantsPublisher.values {
            owner = participants.first { $0.isOwner }
            updateSettingsInfo()
        }
    }
    
    private func updateSettingsInfo() {
        guard let spaceView else { return }
        settingsInfo = spaceSettingsInfoBuilder.build(workspaceInfo: workspaceInfo, details: spaceView, owner: owner) { [weak self] in
            self?.snackBarData = .init(text: Loc.copiedToClipboard($0), showSnackBar: true)
        }
    }
}
