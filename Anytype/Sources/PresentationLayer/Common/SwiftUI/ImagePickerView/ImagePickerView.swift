import SwiftUI
import UniformTypeIdentifiers

enum ImagePickerMediaType {
    case image(_ image: UIImage,_ type: String)
    case video(URL)
}

struct ImagePickerView: UIViewControllerRepresentable {
    
    private let sourceType: UIImagePickerController.SourceType
    private let onMediaTaken: (_ media: ImagePickerMediaType) -> Void
    
    init(sourceType: UIImagePickerController.SourceType, onMediaTaken: @escaping (ImagePickerMediaType) -> Void) {
        self.sourceType = sourceType
        self.onMediaTaken = onMediaTaken
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType) {
            picker.mediaTypes = mediaTypes
        }
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onMediaTaken: onMediaTaken)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let onMediaTaken: (_ media: ImagePickerMediaType) -> Void
        
        init(onMediaTaken: @escaping (ImagePickerMediaType) -> Void) {
            self.onMediaTaken = onMediaTaken
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage,
               let mediaType = info[.mediaType] as? String {
                onMediaTaken(.image(image, mediaType))
            }
            if let url = info[.mediaURL] as? URL {
                onMediaTaken(.video(url))
            }
            picker.dismiss(animated: true)
        }
        
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
