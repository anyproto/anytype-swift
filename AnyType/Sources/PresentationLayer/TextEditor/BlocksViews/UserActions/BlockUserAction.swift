import Foundation
import Combine

typealias BookmarkOutput = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
typealias FilteringPayload = BlocksViews.Toolbar.AddBlock.ViewModel.BlocksTypesCasesFiltering

enum BlockUserAction {
    case file(FileAction)
    case emoji(EmojiPicker.ViewModel)
    
    case addBlock(AddBlock)
    case turnIntoBlock(TurnIntoBlock)
    case bookmark(BookmarkOutput)
}

extension BlockUserAction {
    struct AddBlock {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
        var input: FilteringPayload?
    }
    
    struct TurnIntoBlock {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
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
