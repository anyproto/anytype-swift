import Foundation
    
final class MediaPickerViewModel {
    let type: MediaPickerContentType
    let completion: ((FilePickerResultInformation?) -> Void)
    
    init(type: MediaPickerContentType, completion: @escaping (FilePickerResultInformation?) -> Void) {
        self.type = type
        self.completion = completion
    }
    
    func process(_ url: URL?) {
        completion(
            url.flatMap { FilePickerResultInformation(documentUrl: $0) }
        )
    }
}
