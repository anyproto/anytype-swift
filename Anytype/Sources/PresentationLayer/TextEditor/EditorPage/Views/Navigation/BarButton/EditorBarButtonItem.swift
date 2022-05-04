import SwiftUI

struct EditorBarButtonItem: UIViewRepresentable {
    let image: UIImage
    let state: EditorBarItemState
    let action: () -> ()
    
    func makeUIView(context: Context) -> UIEditorBarButtonItem {
        return UIEditorBarButtonItem(image: image, action: action)
    }
    
    func updateUIView(_ item: UIEditorBarButtonItem, context: Context) {
        item.changeState(state)
    }
}
