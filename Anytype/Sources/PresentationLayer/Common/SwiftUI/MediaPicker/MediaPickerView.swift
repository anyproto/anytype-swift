import PhotosUI
import SwiftUI

// TODO: Migrate to PhotosPicker
struct MediaPickerView: UIViewControllerRepresentable {

    let contentType: MediaPickerContentType
    let onSelect: (NSItemProvider?) -> Void
    
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

extension MediaPickerView {
    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        
        let onSelect: (NSItemProvider?) -> Void
        
        init(onSelect: @escaping (NSItemProvider?) -> Void) {
            self.onSelect = onSelect
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            onSelect(results.first?.itemProvider)
        }
    }
}
