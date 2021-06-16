import PhotosUI
import SwiftUI

struct MediaPickerView: UIViewControllerRepresentable {
    
    @Binding var selectedMediaUrl: URL?
    
    let contentType: MediaPickerContentType
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = contentType.filter
        configuration.selectionLimit = 1
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: MediaPickerView
        
        init(_ parent: MediaPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let chosen = results.first?.itemProvider else {
                return
            }
            
            process(chosen: chosen)
        }
        
        func process(chosen itemProvider: NSItemProvider) {
            itemProvider.loadFileRepresentation(
                forTypeIdentifier: parent.contentType.typeIdentifier
            ) { [weak self] url, error in
                self?.parent.selectedMediaUrl = url
            }
        }
    }
}
