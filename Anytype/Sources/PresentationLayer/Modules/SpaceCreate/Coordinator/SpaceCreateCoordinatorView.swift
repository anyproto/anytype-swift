import SwiftUI
import AnytypeCore

struct SpaceCreateCoordinatorView: View {

    @State private var model: SpaceCreateCoordinatorViewModel
    private let embedInNavigationStack: Bool

    init(data: SpaceCreateData, embedInNavigationStack: Bool = true, onShowHomepagePicker: ((String) -> Void)? = nil) {
        _model = State(initialValue: SpaceCreateCoordinatorViewModel(data: data, onShowHomepagePicker: onShowHomepagePicker))
        self.embedInNavigationStack = embedInNavigationStack
    }

    var body: some View {
        Group {
            if FeatureFlags.createChannelFlow {
                if embedInNavigationStack {
                    NavigationStack {
                        ChannelCreateView(data: model.data, output: model)
                    }
                } else {
                    ChannelCreateView(data: model.data, output: model)
                }
            } else {
                SpaceCreateView(data: model.data, output: model)
            }
        }
        .sheet(item: $model.localObjectIconPickerData) {
            LocalObjectIconPickerView(data: $0)
        }
        .sheet(item: $model.homePagePickerData) { data in
            HomePagePickerView(spaceId: data.spaceId) {
                try await model.onHomePagePickerFinished()
            }.interactiveDismissDisabled(true)
        }
        .sheet(item: $model.newHomepagePickerData) { data in
            HomepagePickerView(spaceId: data.spaceId) { result in
                try await model.onHomepagePickerFinished(result: result)
            }
            .interactiveDismissDisabled(true)
        }
    }
}
