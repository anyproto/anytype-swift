import Foundation

struct ChatFilesPickerData {
    let id = UUID()
    let handler: (_ result: Result<[URL], any Error>) -> Void
}
