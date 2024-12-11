import Foundation
import Combine
import AnytypeCore
import UIKit

@MainActor
final class FileDownloadingViewModel: NSObject, ObservableObject {
    
    @Published private(set) var isErrorOccured: Bool = false
    @Published private(set) var bytesLoaded: Double = 0
    @Published private(set) var bytesExpected: Double = 0
    
    private(set) var errorMessage: String = Constants.defaultErrorMessage
    
    private weak var task: URLSessionDownloadTask?
    
    private weak var output: (any FileDownloadingModuleOutput)?
    
    init(url: URL, output: some FileDownloadingModuleOutput) {
        self.output = output
        
        super.init()
        
        self.downloadFileAt(url)
    }
    
}

extension FileDownloadingViewModel {
    
    func didTapCancelButton() {
        task?.cancel()
        output?.didAskToClose()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func didTapDoneButton() {
        output?.didAskToClose()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
}

// MARK: - URLSessionDownloadDelegate

extension FileDownloadingViewModel: URLSessionDownloadDelegate {
    
    nonisolated func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        MainActor.assumeIsolated {
            handleError(message: error?.localizedDescription)
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        MainActor.assumeIsolated {
            guard
                let error = error as? URLError,
                error.code != .cancelled
            else { return }
            
            handleError(message: error.localizedDescription)
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        MainActor.assumeIsolated {
            handleDownloadTaskCompletion(url: location, response: downloadTask.response)
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        MainActor.assumeIsolated {
            self.bytesLoaded = Double(totalBytesWritten)
            self.bytesExpected = Double(totalBytesExpectedToWrite)
        }
    }
    
}

// MARK: - Private extension

private extension FileDownloadingViewModel {
    
    private func downloadFileAt(_ url: URL) {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = urlSession.downloadTask(with: url)
        self.task = task
        task.resume()
    }
    
    private func handleDownloadTaskCompletion(url: URL, response: URLResponse?) {
        guard let response = response else {
            handleError(message: nil)
            return
        }
        
        var localURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        if let suggestedFileName = response.suggestedFilename {
            localURL.appendPathComponent(suggestedFileName)
        }
        
        if FileManager.default.fileExists(atPath: localURL.relativePath) {
            try? FileManager.default.removeItem(at: localURL)
        }
        
        do {
            try FileManager.default.moveItem(at: url, to: localURL)
            output?.didDownloadFileTo(localURL)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            handleError(message: error.localizedDescription)
            anytypeAssertionFailure(error.localizedDescription)
        }
    }
    
    func handleError(message: String?) {
        errorMessage = message ?? Constants.defaultErrorMessage
        isErrorOccured = true
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
}

private extension FileDownloadingViewModel {
    
    enum Constants {
        static let defaultErrorMessage = Loc.ErrorOccurred.pleaseTryAgain
    }
    
}
