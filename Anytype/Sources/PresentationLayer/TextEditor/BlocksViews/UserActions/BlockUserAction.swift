import Foundation
import Combine

typealias BookmarkOutput = PassthroughSubject<BlockToolbarAction, Never>
typealias FilteringPayload = BlocksTypesCasesFiltering

enum BlockUserAction {
    case file(FileAction)
    
    case addBlock(AddBlock)
    case turnIntoBlock(TurnIntoBlock)
    case bookmark(BookmarkOutput)
}

extension BlockUserAction {
    struct AddBlock {
        var output: PassthroughSubject<BlockToolbarAction, Never>
        var input: FilteringPayload?
    }
    
    struct TurnIntoBlock {
        var output: PassthroughSubject<BlockToolbarAction, Never>
        var input: FilteringPayload?
    }
    
    enum FileAction {
        typealias FilePickerModel = CommonViews.Pickers.File.Picker.ViewModel
        typealias MediaPickerModel = MediaPicker.ViewModel
        
        case shouldShowFilePicker(FilePickerModel)
        case shouldShowImagePicker(MediaPickerModel)
        case shouldUploadFile(filePath: String)
        case shouldSaveFile(fileURL: URL)
    }
}
