import Foundation
import SwiftUI

struct TextIconPickerView: View {
    
    @StateObject private var model: TextIconPickerViewModel
    
    init(data: TextIconPickerData) {
        self._model = StateObject(wrappedValue: TextIconPickerViewModel(data: data))
    }
    
    var body: some View {
        ObjectBasicIconPicker(
            isRemoveButtonAvailable: false,
            mediaPickerContentType: .images,
            onSelectItemProvider: { itemProvider in
                model.uploadImage(from: itemProvider)
            },
            onSelectEmoji: { emoji in
                model.setEmoji(emoji.emoji)
            },
            removeIcon: {}
        )
    }
}
