import SwiftUI

struct GroupChannelCreateCoordinatorView: View {

    @State private var model: GroupChannelCreateCoordinatorViewModel

    init(data: GroupChannelCreateData) {
        _model = State(initialValue: GroupChannelCreateCoordinatorViewModel(contacts: data.contacts))
    }

    var body: some View {
        NavigationStack {
            SelectMembersView(contacts: model.contacts) { selectedMembers in
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
