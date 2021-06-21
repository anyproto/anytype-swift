import Foundation
import Combine

enum BlockUserAction {
    case file(FileAction)
    
    case addBlock(AddBlockOutput)
    case bookmark(BookmarkOutput)
}


typealias BookmarkOutput = PassthroughSubject<BlockToolbarAction, Never>
typealias AddBlockOutput = PassthroughSubject<BlockToolbarAction, Never>

extension BlockUserAction {
    enum FileAction {
        typealias FilePickerModel = CommonViews.Pickers.File.Picker.ViewModel
        typealias MediaPickerModel = MediaPicker.ViewModel
        
        case shouldShowFilePicker(FilePickerModel)
        case shouldShowImagePicker(MediaPickerModel)
        case shouldUploadFile(filePath: String)
        case shouldSaveFile(fileURL: URL)
    }
}
