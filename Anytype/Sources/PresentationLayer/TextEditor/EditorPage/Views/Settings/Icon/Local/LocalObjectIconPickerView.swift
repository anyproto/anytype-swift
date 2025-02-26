import Foundation
import SwiftUI

struct LocalObjectIconPickerData: Identifiable {
    let id = UUID()
    let fileData: FileData?
    let output: any LocalObjectIconPickerOutput
}

struct LocalObjectIconPickerView: View {
    
    @StateObject private var model: LocalObjectIconPickerViewModel
    
    init(data: LocalObjectIconPickerData) {
        self._model = StateObject(wrappedValue: LocalObjectIconPickerViewModel(data: data))
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
