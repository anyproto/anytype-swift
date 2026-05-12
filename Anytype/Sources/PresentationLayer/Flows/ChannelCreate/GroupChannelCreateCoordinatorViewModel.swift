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
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    var selectMembersData: SelectMembersData?
    var spaceCreateData: SpaceCreateData?
    var spaceCreateDataWithEmptyContacts: SpaceCreateData {
        makeSpaceCreateData(contacts: [])
    }
    var contactsEmpty = false

    // MARK: - Lifecycle

    func loadContacts() async {
        let contacts = await contactsService.loadContacts()

        if contacts.isEmpty {
            contactsEmpty = true
        } else {
            let sharedSpaceView = participantSpacesStorage.allParticipantSpaces
                .first { $0.spaceView.isActive && $0.spaceView.isShared && $0.isOwner }?
                .spaceView
            selectMembersData = SelectMembersData(
                contacts: contacts,
                writersLimit: sharedSpaceView?.availableWriterSlots,
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
        spaceCreateData = makeSpaceCreateData(contacts: contacts)
    }
    
    private func makeSpaceCreateData(contacts: [Contact]) -> SpaceCreateData {
        return SpaceCreateData(spaceUxType: .data, selectedContacts: contacts, channelType: .group)
    }
}
