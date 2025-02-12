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
        
        cancellable = EventBunchSubscribtion.default.addHandler { [weak self] events in
            self?.handle(events: events)
        }
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .fileLimitReached:
                fileLimitReachedSubject.send(())
            default:
                break
            }
        }
    }
}
