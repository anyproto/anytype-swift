
import UIKit
import Combine

/// Entity to load file from remote URL
final class FileLoader: NSObject {
    
    private lazy var urlSession: URLSession = .init(configuration: .default, delegate: self, delegateQueue: .main)
    private lazy var progressSubject: PassthroughSubject<FileLoadingState, Error> = .init()
    
    /// Load file from remote resource
    ///
    /// - Parameters:
    ///   - remoteFileURL: Remote file URL
    ///
    /// - Returns: Value with information about downloading file
    func loadFile(remoteFileURL: URL) -> FileLoaderReturnValue {        
        let task = self.urlSession.downloadTask(with: remoteFileURL) { [weak self] tempURL, response, error in
            if let error = error {
                self?.progressSubject.send(completion: .failure(error))
                return
            }
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
                self?.progressSubject.send(.loaded(localURL))
                self?.progressSubject.send(completion: .finished)
            } catch {
                assertionFailure(error.localizedDescription)
                self?.progressSubject.send(completion: .failure(error))
            }
        }
        task.resume()
        return FileLoaderReturnValue(task: task, progressPublisher: self.progressSubject.eraseToAnyPublisher())
    }
}

extension FileLoader: URLSessionDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            self.progressSubject.send(.loading(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)))
        }
    }
}

extension URLSessionTask: Cancellable {}
