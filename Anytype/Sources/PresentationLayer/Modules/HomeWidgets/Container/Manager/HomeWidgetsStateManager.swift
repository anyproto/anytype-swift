import Foundation
import Combine

protocol HomeWidgetsStateManagerProtocol: AnyObject {
    var isEditStatePublisher: AnyPublisher<Bool, Never> { get }
    func setEditState(_ state: Bool)
}

final class HomeWidgetsStateManager: HomeWidgetsStateManagerProtocol {
    
    @Published private var isEditState: Bool = false
    var isEditStatePublisher: AnyPublisher<Bool, Never> {
        $isEditState.eraseToAnyPublisher()
    }
    
    init() {}
    
    func setEditState(_ state: Bool) {
        isEditState = state
    }
}
