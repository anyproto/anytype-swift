import SwiftUI

struct SpaceCreateCoordinatorView: View {

    @StateObject private var model: SpaceCreateCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: SpaceCreateData) {
        self._model = StateObject(wrappedValue: SpaceCreateCoordinatorViewModel(data: data))
    }

    var body: some View {
        SpaceCreateView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.localObjectIconPickerData) {
            LocalObjectIconPickerView(data: $0)
        }
        .sheet(item: $model.spaceStartWithData) { data in
            SpaceStartWithPickerView(data: data) { option in
                model.onStartWithOptionSelected(option, spaceId: data.spaceId)
            }
        }
        .onChange(of: model.dismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}
