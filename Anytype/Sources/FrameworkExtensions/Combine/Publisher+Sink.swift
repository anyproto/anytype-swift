import Combine
import AnytypeCore

extension Publisher {
    public func sinkWithResult(completion: @escaping (Result<Self.Output, any Error>) -> ()) -> AnyCancellable {
        self.sink { sinkCompletion in
            switch sinkCompletion {
            case .finished: return
            case let .failure(error):
                completion(.failure(error))
            }
        } receiveValue: { result in
            completion(.success(result))
        }
    }
}
