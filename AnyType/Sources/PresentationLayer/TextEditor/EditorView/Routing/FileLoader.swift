
import UIKit

/// Entity to load file from remote URL
final class FileLoader {
    
    private let remoteFileURL: URL
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - remoteFileURL: Remote file URL
    init(remoteFileURL: URL) {
        self.remoteFileURL = remoteFileURL
    }
    
    func loadFile(completion: @escaping(URL) -> Void) {
        let task = URLSession.shared.downloadTask(with: self.remoteFileURL) { tempURL, response, _ in
            guard let tempURL = tempURL, let response = response else { return }
            var localURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                               isDirectory: true)
            if let suggestedFileName = response.suggestedFilename {
                localURL.appendPathComponent(suggestedFileName)
            }
            if let fileExtension = response.mimeType?.components(separatedBy: "/").last {
                localURL.deletePathExtension()
                localURL.appendPathExtension(fileExtension)
            }
            if FileManager.default.fileExists(atPath: localURL.relativePath) {
                try? FileManager.default.removeItem(at: localURL)
            }
            do {
                try FileManager.default.moveItem(at: tempURL, to: localURL)
                completion(localURL)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        task.resume()
    }
}
