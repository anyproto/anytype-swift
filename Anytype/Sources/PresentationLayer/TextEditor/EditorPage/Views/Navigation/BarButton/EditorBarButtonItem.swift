import SwiftUI

struct EditorBarButtonItem: UIViewRepresentable {
    let image: UIImage
    let action: () -> ()
    
    func makeUIView(context: Context) -> UIEditorBarButtonItem {
        return UIEditorBarButtonItem(image: image, action: action)
    }
    
    func updateUIView(_ uiView: UIEditorBarButtonItem, context: Context) {
    }
}
