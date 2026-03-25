import Foundation
import Services
import Combine
import Loc

@MainActor
@Observable
final class SelectMembersViewModel {

    let contacts: [Contact]
    let onNext: ([SelectedMember]) -> Void

    var searchText: String = ""
    var selectedIdentities: [String] = [] // ordered array, not Set

    // TODO: IOS-5904 — replace hardcoded limit with real tier data
    private let writersLimit: Int = 10
    private let viewersLimit: Int = 1000

    init(contacts: [Contact], onNext: @escaping ([SelectedMember]) -> Void) {
        self.contacts = contacts
        self.onNext = onNext
    }

    // MARK: - Computed

    var filteredContacts: [Contact] {
        guard searchText.isNotEmpty else { return contacts }
        return contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.globalName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var editorsCount: Int {
        min(selectedIdentities.count, writersLimit)
    }

    var viewersCount: Int {
        max(0, selectedIdentities.count - writersLimit)
    }

    var subtitle: String {
        Loc.Channel.Create.SelectMembers.editorsCount(editorsCount, writersLimit) +
        " · " +
        Loc.Channel.Create.SelectMembers.viewersCount(viewersCount, viewersLimit)
    }

    // MARK: - Actions

    func isSelected(_ contact: Contact) -> Bool {
        selectedIdentities.contains(contact.identity)
    }

    func toggle(_ contact: Contact) {
        if let index = selectedIdentities.firstIndex(of: contact.identity) {
            selectedIdentities.remove(at: index)
        } else {
            selectedIdentities.append(contact.identity)
        }
    }

    func onTapNext() {
        let members = buildSelectedMembers()
        onNext(members)
    }

    // MARK: - Private

    private func buildSelectedMembers() -> [SelectedMember] {
        selectedIdentities.enumerated().map { index, identity in
            let role: ParticipantPermissions = index >= writersLimit ? .reader : .writer
            return SelectedMember(identity: identity, role: role)
        }
    }
}
