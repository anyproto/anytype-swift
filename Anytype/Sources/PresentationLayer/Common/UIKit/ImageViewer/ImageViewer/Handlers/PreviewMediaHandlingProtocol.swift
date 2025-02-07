import Foundation

protocol PreviewMediaHandlingProtocol {
    var output: (any PreviewMediaHandlingOutput)? { get set }
    func startDownloading()
}

protocol PreviewMediaHandlingOutput: AnyObject {
    func onUpdate(path: URL)
}
