import Foundation
import SwiftUI

struct YamlDocumentPicker: UIViewControllerRepresentable {
    
    var onSelect: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.yaml])
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> ServerDocumentPickerCoordinator {
        ServerDocumentPickerCoordinator(onSelect: onSelect)
    }
}

class ServerDocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    
    var onSelect: (URL) -> Void

    init(onSelect: @escaping (URL) -> Void) {
        self.onSelect = onSelect
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        onSelect(url)
    }
}
