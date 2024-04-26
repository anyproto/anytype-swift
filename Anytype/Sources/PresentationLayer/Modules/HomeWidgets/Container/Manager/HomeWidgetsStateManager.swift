import Foundation
import Combine

protocol HomeWidgetsStateManagerProtocol: AnyObject {
    var isEditState: Bool { get }
    var isEditStatePublisher: AnyPublisher<Bool, Never> { get }
    func setEditState(_ state: Bool)
}

final class HomeWidgetsStateManager: HomeWidgetsStateManagerProtocol {
    
    @Published private(set) var isEditState: Bool = false
    var isEditStatePublisher: AnyPublisher<Bool, Never> {
        $isEditState.eraseToAnyPublisher()
    }
    
    init() {}
    
    func setEditState(_ state: Bool) {
        isEditState = state
    }
}
