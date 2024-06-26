import Combine
import Foundation

/// Information about downloading file
final class FileLoaderReturnValue {
    
    /// Download task with possibility to cancel it
    let task: any Cancellable
    
    /// Progress publisher to subscribe on progress changes
    let progressPublisher: AnyPublisher<FileLoadingState, any Error>
    
    /// initializer
    ///
    /// - Parameters:
    ///   - task: Download task with possibility to cancel it
    ///   - progressPublisher: Progress publisher to subscribe on progress changes
    init(
        task: some Cancellable,
        progressPublisher: AnyPublisher<FileLoadingState, any Error>
    ) {
        self.task = task
        self.progressPublisher = progressPublisher
    }
}
