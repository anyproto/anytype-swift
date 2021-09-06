import UIKit
import Combine
import AnytypeCore

/// Entity to load file from remote URL
final class FileLoader: NSObject {
    
    private lazy var urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    private lazy var tasksToSubjects = NSMapTable<URLSessionDownloadTask, PassthroughSubject<FileLoadingState, Error>>.strongToWeakObjects()
    
    
    func loadFile(remoteFileURL: URL) -> FileLoaderReturnValue {
        let progressSubject = PassthroughSubject<FileLoadingState, Error>()
        let task = self.urlSession.downloadTask(with: remoteFileURL) { tempURL, response, error in
            if let error = error {
                progressSubject.send(completion: .failure(error))
                return
            }
            guard let tempURL = tempURL, let response = response else { return }
            var localURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                               isDirectory: true)
            if let suggestedFileName = response.suggestedFilename {
                localURL.appendPathComponent(suggestedFileName)
            }
            if FileManager.default.fileExists(atPath: localURL.relativePath) {
                try? FileManager.default.removeItem(at: localURL)
            }
            do {
                try FileManager.default.moveItem(at: tempURL, to: localURL)
                progressSubject.send(.loaded(localURL))
                progressSubject.send(completion: .finished)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
                progressSubject.send(completion: .failure(error))
            }
        }
        self.tasksToSubjects.setObject(progressSubject, forKey: task)
        task.resume()
        return FileLoaderReturnValue(task: task, progressPublisher: progressSubject.eraseToAnyPublisher())
    }
}

extension FileLoader: URLSessionDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0,
              let progressSubject = self.tasksToSubjects.object(forKey: downloadTask) else {
            return
        }
        progressSubject.send(.loading(bytesLoaded: totalBytesWritten, totalBytesCount: totalBytesExpectedToWrite))
    }
}

extension URLSessionTask: Cancellable {}
