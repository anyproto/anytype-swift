import Combine
import AnytypeCore

extension Publisher {
    public func sinkWithDefaultCompletion(_ actionName: String, receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: defaultCompletion(actionName), receiveValue: receiveValue)
    }
    
    private func defaultCompletion(_ actionName: String) -> ((Subscribers.Completion<Self.Failure>) -> Void) {
        return { completion in
            switch completion {
            case .finished: return
            case let .failure(error):
                anytypeAssertionFailure("\(actionName) error: \(error)")
            }
        }
    }
}
