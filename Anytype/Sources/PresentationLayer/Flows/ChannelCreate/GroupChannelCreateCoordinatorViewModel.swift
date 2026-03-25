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
            spaceCreateData = SpaceCreateData(spaceUxType: .data)
        } else {
            selectMembersData = SelectMembersData(contacts: contacts, writersLimit: writersLimit)
        }
    }

    // MARK: - SelectMembers output

    func onSelectMembersNext(_ members: [SelectedMember]) {
        selectedMembers = members
        spaceCreateData = SpaceCreateData(spaceUxType: .data)
        // TODO: IOS-5904 — pass selectedMembers to SpaceCreate (separate task)
    }
}
