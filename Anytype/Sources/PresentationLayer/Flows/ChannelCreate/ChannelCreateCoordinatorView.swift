import SwiftUI

struct ChannelCreateCoordinatorView: View {

    @State private var model: ChannelCreateCoordinatorViewModel

    init(type: ChannelCreateType) {
        _model = State(initialValue: ChannelCreateCoordinatorViewModel(type: type))
    }

    var body: some View {
        NavigationStack {
            stepView
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

    @ViewBuilder
    private var stepView: some View {
        switch model.step {
        case .loading:
            ProgressView()
        case .selectMembers(let contacts, let writersLimit):
            SelectMembersView(contacts: contacts, writersLimit: writersLimit) { selectedMembers in
                model.onSelectMembersNext(selectedMembers)
            }
        }
    }
}
