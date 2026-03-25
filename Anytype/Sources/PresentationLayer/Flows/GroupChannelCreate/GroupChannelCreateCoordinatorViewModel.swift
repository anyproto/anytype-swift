import SwiftUI
import Factory
import AnytypeCore

@MainActor
@Observable
final class GroupChannelCreateCoordinatorViewModel: SpaceCreateModuleOutput {

    @ObservationIgnored
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @ObservationIgnored
    @Injected(\.contactsService)
    private var contactsService: any ContactsServiceProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    var contacts: [Contact] = []
    var writersLimit: Int?
    var isLoading = true
    var showSpaceCreate = false
    var selectedMembers: [SelectedMember] = []
    var localObjectIconPickerData: LocalObjectIconPickerData?
    var newHomepagePickerData: HomePagePickerData?

    @ObservationIgnored
    private var pendingSpaceId: String?

    // MARK: - Lifecycle

    func onAppear() {
        Task {
            contacts = await contactsService.loadContacts()
            writersLimit = spaceViewsStorage.allSpaceViews
                .first { $0.isActive && $0.isShared }?.writersLimit
            isLoading = false

            if contacts.isEmpty {
                showSpaceCreate = true
            }
        }
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
