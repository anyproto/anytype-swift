import Foundation
import Combine

extension Task {
    func cancellable() -> AnyCancellable {
        AnyCancellable {
            if !isCancelled {
                cancel()
            }
        }
    }
}
