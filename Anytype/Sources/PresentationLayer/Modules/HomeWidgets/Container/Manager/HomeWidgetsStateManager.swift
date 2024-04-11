import Foundation
import Combine

enum HomeWidgetsState {
    case readwrite
    case readonly
    case editWidgets
}

extension HomeWidgetsState {
    var isEditWidgets: Bool {
        self == .editWidgets
    }
    
    var isReadWrite: Bool {
        self == .readwrite
    }
    
    var isReadOnly: Bool {
        self == .readonly
    }
}

// TODO: Delete. Use Binding between module and submodules
protocol HomeWidgetsStateManagerProtocol: AnyObject {
    var homeState: HomeWidgetsState { get }
    var homeStatePublisher: AnyPublisher<HomeWidgetsState, Never> { get }
    func setHomeState(_ state: HomeWidgetsState)
}

final class HomeWidgetsStateManager: HomeWidgetsStateManagerProtocol {
        
    @Published private(set) var homeState: HomeWidgetsState = .readonly
    var homeStatePublisher: AnyPublisher<HomeWidgetsState, Never> {
        $homeState.eraseToAnyPublisher()
    }
    
    init() {}
    
    func setHomeState(_ state: HomeWidgetsState) {
        homeState = state
    }
}
