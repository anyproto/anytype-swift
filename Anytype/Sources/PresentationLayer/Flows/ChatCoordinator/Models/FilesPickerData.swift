import Foundation

struct FilesPickerData {
    let id = UUID()
    let handler: (_ result: Result<[URL], any Error>) -> Void
}
