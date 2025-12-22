import SwiftUI
import AnytypeCore

struct ObjectSettingsMenuContainer<Label: View>: View {

    @StateObject private var model: ObjectSettingsCoordinatorViewModel
    private let label: () -> Label

    init(
        objectId: String,
        spaceId: String,
        output: (any ObjectSettingsCoordinatorOutput)?,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._model = StateObject(wrappedValue: ObjectSettingsCoordinatorViewModel(objectId: objectId, spaceId: spaceId, output: output))
        self.label = label
    }

    var body: some View {
        ObjectSettingsMenuView(objectId: model.objectId, spaceId: model.spaceId, output: model, labelView: label)
            .sheet(item: $model.coverPickerData) {
                ObjectCoverPicker(data: $0)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(item: $model.blockObjectSearchData) {
                BlockObjectSearchView(data: $0)
            }
            .sheet(item: $model.relationsListData) {
                PropertiesListCoordinatorView(document: $0.document, output: model)
            }
            .sheet(item: $model.versionHistoryData) {
                VersionHistoryCoordinatorView(data: $0, output: model)
            }
            .sheet(item: $model.publishingData) {
                PublishToWebCoordinator(data: $0)
            }
    }
}

extension ObjectSettingsMenuContainer where Label == AnyView {
    init(objectId: String, spaceId: String, output: (any ObjectSettingsCoordinatorOutput)?) {
        self.init(objectId: objectId, spaceId: spaceId, output: output) {
            AnyView(
                Image(asset: .X24.more)
                    .foregroundStyle(Color.Text.primary)
            )
        }
    }
}
