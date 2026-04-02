import Foundation
import Services
import Loc

@MainActor
@Observable
final class SelectMembersViewModel {

    let contacts: [Contact]
    let onNext: ([SelectedMember]) -> Void

    var searchText: String = ""
    var selectedIdentities: [String] = [] // ordered array, not Set

    private let writersLimit: Int?
    private let readersLimit: Int?

    init(contacts: [Contact], writersLimit: Int?, readersLimit: Int?, onNext: @escaping ([SelectedMember]) -> Void) {
        self.contacts = contacts
        self.writersLimit = writersLimit
        self.readersLimit = readersLimit
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
        guard let writersLimit else { return selectedIdentities.count }
        return min(selectedIdentities.count, writersLimit)
    }

    var viewersCount: Int {
        guard let writersLimit else { return 0 }
        return max(0, selectedIdentities.count - writersLimit)
    }

    var showSubtitle: Bool {
        writersLimit != nil
    }

    var subtitle: String {
        guard let writersLimit else { return "" }
        return Loc.Channel.Create.SelectMembers.editorsCount(editorsCount, writersLimit) +
        ", " +
        Loc.Channel.Create.SelectMembers.viewersCount(viewersCount, readersLimit ?? 0)
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
            let role: ParticipantPermissions
            if let writersLimit, index >= writersLimit {
                role = .reader
            } else {
                role = .writer
            }
            return SelectedMember(identity: identity, role: role)
        }
    }
}
