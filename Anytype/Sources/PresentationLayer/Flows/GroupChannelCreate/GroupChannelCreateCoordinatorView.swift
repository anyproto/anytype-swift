import SwiftUI

struct GroupChannelCreateCoordinatorView: View {

    @State private var model: GroupChannelCreateCoordinatorViewModel

    init(data: GroupChannelCreateData) {
        _model = State(initialValue: GroupChannelCreateCoordinatorViewModel(contacts: data.contacts, writersLimit: data.writersLimit))
    }

    var body: some View {
        NavigationStack {
            SelectMembersView(contacts: model.contacts, writersLimit: model.writersLimit) { selectedMembers in
                model.onSelectMembersNext(selectedMembers)
            }
            .navigationDestination(isPresented: $model.showSpaceCreate) {
                SpaceCreateView(
                    data: SpaceCreateData(spaceUxType: .data),
                    output: model
                )
            }
        }
        .sheet(item: $model.localObjectIconPickerData) {
            LocalObjectIconPickerView(data: $0)
        }
        .sheet(item: $model.newHomepagePickerData) { data in
            HomepagePickerView(spaceId: data.spaceId) { result in
                try await model.onHomepagePickerFinished(result: result)
            }
            .interactiveDismissDisabled(true)
        }
    }
}
