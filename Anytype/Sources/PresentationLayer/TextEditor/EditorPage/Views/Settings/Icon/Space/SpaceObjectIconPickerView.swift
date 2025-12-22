import Foundation
import SwiftUI

struct SpaceObjectIconPickerView: View {

    @State private var model: SpaceObjectIconPickerViewModel

    init(spaceId: String) {
        _model = State(initialValue: SpaceObjectIconPickerViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        ObjectProfileIconPicker(
            isRemoveEnabled: model.isRemoveEnabled,
            mediaPickerContentType: .images,
            onSelectItemProvider: { itemProvider in
                model.uploadImage(from: itemProvider)
            },
            removeIcon: {
                model.removeIcon()
            }
        )
        .task {
            await model.startSpaceTask()
        }
    }
}
