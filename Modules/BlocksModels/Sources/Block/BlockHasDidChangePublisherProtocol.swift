import Foundation
import Combine


/// Deprecated. Could be removed in future revisions.
public protocol BlockHasDidChangePublisherProtocol {
    func didChangePublisher() -> AnyPublisher<Void, Never>
    func didChange()
    func didChangeInformationPublisher() -> AnyPublisher<BlockInformation, Never>
}
