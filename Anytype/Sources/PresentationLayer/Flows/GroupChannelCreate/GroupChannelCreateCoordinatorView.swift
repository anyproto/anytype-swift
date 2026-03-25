import SwiftUI

struct GroupChannelCreateCoordinatorView: View {

    @State private var model = GroupChannelCreateCoordinatorViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if model.isLoading {
                    ProgressView()
                } else if model.contacts.isNotEmpty {
                    SelectMembersView(contacts: model.contacts, writersLimit: model.writersLimit) { selectedMembers in
                        model.onSelectMembersNext(selectedMembers)
                    }
                }
            }
            .navigationDestination(isPresented: $model.showSpaceCreate) {
                SpaceCreateView(
                    data: SpaceCreateData(spaceUxType: .data),
                    output: model
                )
            }
        }
        .task {
            model.onAppear()
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
