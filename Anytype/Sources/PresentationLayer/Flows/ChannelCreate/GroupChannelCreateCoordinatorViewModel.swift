import SwiftUI
import Factory
import AnytypeCore

@MainActor
@Observable
final class GroupChannelCreateCoordinatorViewModel {

    @ObservationIgnored
    @Injected(\.contactsService)
    private var contactsService: any ContactsServiceProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    var selectMembersData: SelectMembersData?
    var spaceCreateData: SpaceCreateData?

    // MARK: - Lifecycle

    func loadContacts() async {
        let contacts = await contactsService.loadContacts()
        let sharedSpaceView = spaceViewsStorage.allSpaceViews
            .first { $0.isActive && $0.isShared }

        if contacts.isEmpty {
            spaceCreateData = SpaceCreateData(spaceUxType: .data, channelType: .group)
        } else {
            selectMembersData = SelectMembersData(
                contacts: contacts,
                writersLimit: sharedSpaceView?.writersLimit,
                readersLimit: sharedSpaceView?.readersLimit
            )
        }
    }

    // MARK: - SelectMembers output

    func onSelectMembersNext(_ members: [SelectedMember]) {
        let selectedIdentities = Set(members.map(\.identity))
        let contacts = selectMembersData?.contacts
            .filter { selectedIdentities.contains($0.identity) }
            .sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending } ?? []
        spaceCreateData = SpaceCreateData(spaceUxType: .data, selectedContacts: contacts, channelType: .group)
    }
}
