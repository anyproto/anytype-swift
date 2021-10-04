import Foundation
    
struct MediaPickerViewModel {
    let type: MediaPickerContentType
    let completion: (NSItemProvider?) -> Void
}
