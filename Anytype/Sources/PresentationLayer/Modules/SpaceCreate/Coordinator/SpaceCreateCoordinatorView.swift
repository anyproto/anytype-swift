import SwiftUI
import AnytypeCore

struct SpaceCreateCoordinatorView: View {

    @State private var model: SpaceCreateCoordinatorViewModel
    private let embedInNavigationStack: Bool

    init(data: SpaceCreateData, embedInNavigationStack: Bool = true) {
        _model = State(initialValue: SpaceCreateCoordinatorViewModel(data: data))
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
    }
}
