import SwiftUI

struct SelectMembersView: View {

    @State private var model: SelectMembersViewModel

    init(contacts: [Contact], writersLimit: Int?, onNext: @escaping ([SelectedMember]) -> Void) {
        _model = State(initialValue: SelectMembersViewModel(contacts: contacts, writersLimit: writersLimit, onNext: onNext))
    }

    var body: some View {
        PlainList {
            ForEach(model.filteredContacts) { contact in
                MemberSelectionRow(
                    icon: contact.icon,
                    name: contact.name,
                    globalName: contact.globalName,
                    isSelected: Binding(
                        get: { model.isSelected(contact) },
                        set: { _ in model.toggle(contact) }
                    )
                )
            }
        }
        .searchable(text: $model.searchText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarNavigationBarOpaqueBackgroundLegacy()
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(Loc.Channel.Create.SelectMembers.title)
                        .anytypeStyle(.uxTitle1Semibold)
                    if model.showSubtitle {
                        Text(model.subtitle)
                            .anytypeStyle(.caption1Regular)
                            .foregroundStyle(Color.Text.secondary)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(Loc.Channel.Create.SelectMembers.next) {
                    model.onTapNext()
                }
            }
        }
    }
}
