import Foundation
import SwiftUI

struct LocalObjectIconPickerView: View {
    
    @StateObject private var model: LocalObjectIconPickerViewModel
    
    init(fileData: FileData?, output: (any LocalObjectIconPickerOutput)?) {
        self._model = StateObject(wrappedValue: LocalObjectIconPickerViewModel(fileData: fileData, output: output))
    }
    
    var body: some View {
        ObjectProfileIconPicker(
            isRemoveEnabled: model.isRemoveEnabled,
            mediaPickerContentType: .images,
            onSelectItemProvider: { itemProvider in
                model.onSelectItemProvider(itemProvider)
            },
            removeIcon: {
                model.removeIcon()
            }
        )
        .task(item: model.itemProvider) { itemProvider in
            await model.itemProviderUpdated(itemProvider.sendable())
        }
    }
}
