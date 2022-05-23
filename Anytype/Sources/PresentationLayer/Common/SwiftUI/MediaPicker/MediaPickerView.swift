import PhotosUI
import SwiftUI

struct MediaPickerView: UIViewControllerRepresentable {

    let contentType: MediaPickerContentType
    let onSelect: (NSItemProvider?) -> Void
    
    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let onSelect: (NSItemProvider?) -> Void
        
        init(onSelect: @escaping (NSItemProvider?) -> Void) {
            self.onSelect = onSelect
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            onSelect(results.first?.itemProvider)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = contentType.filter
        configuration.selectionLimit = 1
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
