import PhotosUI
import AnytypeCore

final class MediaPicker: UIViewController {
    
    private let viewModel: MediaPickerViewModel
        
    // MARK: - Initializer
    
    init(viewModel: MediaPickerViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override functions
    
    override func loadView() {
        super.loadView()
        
        configureView()
    }
    
}

// MARK: - Appearance

private extension MediaPicker {
    
    func configureView() {
        var configuration = PHPickerConfiguration()
        configuration.filter = viewModel.type.filter
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        embedChild(picker)
        picker.view.pinAllEdges(to: view)
    }
    
}

// MARK: - UIDocumentPickerDelegate
extension MediaPicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        viewModel.completion(results.first?.itemProvider)
        dismiss(animated: true)
    }
    
}
