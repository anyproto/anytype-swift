import Foundation


struct DiscussionFilesPickerData {
    let id = UUID()
    let handler: (_ result: Result<[URL], any Error>) -> Void
}
