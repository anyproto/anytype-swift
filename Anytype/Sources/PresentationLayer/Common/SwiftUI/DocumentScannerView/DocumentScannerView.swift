import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    
    typealias Completion = (Result<[UIImage], any Error>) -> Void
    
    private let completion: Completion
    
    init(completion: @escaping Completion) {
        self.completion = completion
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        private let completion: Completion
        
        init(completion: @escaping Completion) {
            self.completion = completion
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            
            for pageIndex in 0..<scan.pageCount {
                let scannedImage = scan.imageOfPage(at: pageIndex)
                images.append(scannedImage)
            }
            
            Task { @MainActor in controller.dismiss(animated: true) }
            completion(.success(images))
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            Task { @MainActor in controller.dismiss(animated: true) }
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            Task { @MainActor in controller.dismiss(animated: true) }
            completion(.failure(error))
        }
    }
}
