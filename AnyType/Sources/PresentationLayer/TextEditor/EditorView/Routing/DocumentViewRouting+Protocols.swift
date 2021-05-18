import Foundation
import Combine

/// This protocol provides publisher that is delivering output events to outer world.
/// We could subscribe on this publisher and could receive events.
/// It is necessary for routing purposes.
/// We could subscribe on this publisher in our `UIViewController`, for example.
protocol DocumentViewRoutingOutputProtocol {
    var outputEventsPublisher: AnyPublisher<DocumentViewRoutingOutputEvent, Never> {get}
}

/// This protocol provides `.send` method that is sending events to outer world.
/// However, it is only for `internal` usage, so, you `don't` need to invoke this method directly.
protocol DocumentViewRoutingSendingOutputProtocol {
    func send(event: DocumentViewRoutingOutputEvent)
}
