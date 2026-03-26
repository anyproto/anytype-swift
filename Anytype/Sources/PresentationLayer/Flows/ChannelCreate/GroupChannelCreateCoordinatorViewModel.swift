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
    var selectedMembers: [SelectedMember] = []

    init() {
        Task { await loadContacts() }
    }

    // MARK: - Private

    private func loadContacts() async {
        let contacts = await contactsService.loadContacts()
        let writersLimit = spaceViewsStorage.allSpaceViews
            .first { $0.isActive && $0.isShared }?.writersLimit

        if contacts.isEmpty {
            spaceCreateData = SpaceCreateData(spaceUxType: .data, channelType: .group)
        } else {
            selectMembersData = SelectMembersData(contacts: contacts, writersLimit: writersLimit)
        }
    }

    // MARK: - SelectMembers output

    func onSelectMembersNext(_ members: [SelectedMember]) {
        selectedMembers = members
        let selectedIdentities = Set(members.map(\.identity))
        let contacts = selectMembersData?.contacts
            .filter { selectedIdentities.contains($0.identity) }
            .sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending } ?? []
        spaceCreateData = SpaceCreateData(spaceUxType: .data, selectedContacts: contacts, channelType: .group)
    }
}
