import Foundation
import Combine

enum ApplicationState {
    case initial
    case login
    case home
    case auth
    case delete
}

protocol ApplicationStateServiceProtocol: AnyObject {
    var statePublisher: AnyPublisher<ApplicationState, Never> { get }
    var state: ApplicationState { get set }
}

final class ApplicationStateService: ApplicationStateServiceProtocol {
    
    // MARK: - ApplicationStateServiceProtocol
    
    @Published var state: ApplicationState = .initial
    
    var statePublisher: AnyPublisher<ApplicationState, Never> {
        $state.eraseToAnyPublisher()
    }
}
