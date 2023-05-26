import Foundation
import ProtobufMessages
import Combine

protocol FileErrorEventHandlerProtocol: AnyObject {
    var fileLimitReachedPublisher: AnyPublisher<Void, Never> { get }
    
    func startSubscription()
}

final class FileErrorEventHandler: FileErrorEventHandlerProtocol {
    
    // MARK: - Private properties
    
    private let fileLimitReachedSubject = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    
    // MARK: - FileErrorEventHandlerProtocol
    
    var fileLimitReachedPublisher: AnyPublisher<Void, Never> {
        fileLimitReachedSubject.eraseToAnyPublisher()
    }
    
    func startSubscription() {
        guard cancellable == nil else { return }
        
        cancellable = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
        .compactMap { $0.object as? EventsBunch }
        .map(\.middlewareEvents)
        .sink { [weak self] events in
            events.forEach { self?.handleEvent($0) }
        }
    }
    
    // MARK: - Private
    
    private func handleEvent(_ event: Anytype_Event.Message) {
        switch event.value {
        case .fileLimitReached:
            fileLimitReachedSubject.send(())
        default:
            break
        }
    }
}
