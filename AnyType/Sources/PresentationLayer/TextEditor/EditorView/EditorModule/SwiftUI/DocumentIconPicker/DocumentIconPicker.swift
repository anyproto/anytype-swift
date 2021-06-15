import SwiftUI

struct DocumentIconPicker: View {
    var body: some View {
        VStack {
            DragIndicator()
            EmojiGridView()
        }
    }
}

struct DocumentIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentIconPicker()
    }
}
