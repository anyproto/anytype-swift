import Foundation
import SwiftUI

struct SpaceObjectIconPickerView: View {
    
    @StateObject private var model: SpaceObjectIconPickerViewModel
    
    init(spaceViewId: String) {
        self._model = StateObject(wrappedValue: SpaceObjectIconPickerViewModel(spaceViewId: spaceViewId))
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
            await model.startDocumentHandler()
        }
    }
}
