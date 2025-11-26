import SwiftUI
import AnytypeCore

struct ObjectSettingsMenuContainer: View {

    @StateObject private var model: ObjectSettingsCoordinatorViewModel

    init(objectId: String, spaceId: String, output: (any ObjectSettingsCoordinatorOutput)?) {
        self._model = StateObject(wrappedValue: ObjectSettingsCoordinatorViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }

    var body: some View {
        ObjectSettingsMenuView(objectId: model.objectId, spaceId: model.spaceId, output: model)
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
