import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: View {
    
    let contentTypes: [UTType]
    let onSelect: (URL) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        DocumentPickerWrapper(contentTypes: contentTypes) { url in
            onSelect(url)
            dismiss()
        }
        .ignoresSafeArea()
    }
}

fileprivate struct DocumentPickerWrapper: UIViewControllerRepresentable {
    
    let contentTypes: [UTType]
    let onSelect: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        DocumentPickerCoordinator(onSelect: onSelect)
    }
}

fileprivate class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    
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
