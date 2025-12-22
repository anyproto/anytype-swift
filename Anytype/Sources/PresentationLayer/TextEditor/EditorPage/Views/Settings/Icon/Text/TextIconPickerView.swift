import Foundation
import SwiftUI

struct TextIconPickerView: View {

    @State private var model: TextIconPickerViewModel

    init(data: TextIconPickerData) {
        _model = State(initialValue: TextIconPickerViewModel(data: data))
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
