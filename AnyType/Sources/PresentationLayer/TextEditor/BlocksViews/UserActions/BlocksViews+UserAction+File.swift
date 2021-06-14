import Foundation

fileprivate typealias Namespace = BlocksViews.UserAction

extension Namespace {
    enum File {}
}

extension Namespace.File {
    enum FileAction {
        typealias FilePickerModel = CommonViews.Pickers.File.Picker.ViewModel
        typealias MediaPickerModel = MediaPicker.ViewModel
        
        case shouldShowFilePicker(FilePickerModel)
        case shouldShowImagePicker(MediaPickerModel)
        case shouldUploadFile(filePath: String)
        case shouldSaveFile(fileURL: URL)
    }
}
