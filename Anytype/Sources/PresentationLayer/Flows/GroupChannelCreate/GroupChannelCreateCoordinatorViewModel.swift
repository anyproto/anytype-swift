import SwiftUI
import Factory
import AnytypeCore

@MainActor
@Observable
final class GroupChannelCreateCoordinatorViewModel: SpaceCreateModuleOutput {

    @ObservationIgnored
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol

    let contacts: [Contact]
    let writersLimit: Int?

    var showSpaceCreate = false
    var selectedMembers: [SelectedMember] = []
    var localObjectIconPickerData: LocalObjectIconPickerData?
    var newHomepagePickerData: HomePagePickerData?

    @ObservationIgnored
    private var pendingSpaceId: String?

    init(contacts: [Contact], writersLimit: Int?) {
        self.contacts = contacts
        self.writersLimit = writersLimit
    }

    // MARK: - SelectMembers output

    func onSelectMembersNext(_ members: [SelectedMember]) {
        selectedMembers = members
        showSpaceCreate = true
    }

    // MARK: - SpaceCreateModuleOutput

    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput) {
        localObjectIconPickerData = LocalObjectIconPickerData(
            fileData: fileData,
            output: output
        )
    }

    func onSpaceCreated(spaceId: String) async throws {
        if FeatureFlags.homePage {
            pendingSpaceId = spaceId
            newHomepagePickerData = HomePagePickerData(spaceId: spaceId)
        } else {
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
        }
        // TODO: IOS-5904 — pass selectedMembers to ParticipantAdd (separate task)
    }

    func onHomepagePickerFinished(result: HomepagePickerResult) async throws {
        guard let spaceId = pendingSpaceId else { return }
        pendingSpaceId = nil

        switch result {
        case .homepageSet:
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
        case .later:
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
            // TODO: Handle temporary widgets (separate task)
        }
    }
}
