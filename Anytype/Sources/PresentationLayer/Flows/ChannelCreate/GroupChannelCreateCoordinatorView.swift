import SwiftUI

struct GroupChannelCreateCoordinatorView: View {

    @State private var model = GroupChannelCreateCoordinatorViewModel()

    var body: some View {
        NavigationStack {
            contentView
                .navigationDestination(item: $model.spaceCreateData) { data in
                    SpaceCreateCoordinatorView(data: data, embedInNavigationStack: false)
                }
        }
        .tint(Color.Text.secondary)
    }

    @ViewBuilder
    private var contentView: some View {
        if let data = model.selectMembersData {
            SelectMembersView(contacts: data.contacts, writersLimit: data.writersLimit) { selectedMembers in
                model.onSelectMembersNext(selectedMembers)
            }
        } else {
            ProgressView()
        }
    }
}
