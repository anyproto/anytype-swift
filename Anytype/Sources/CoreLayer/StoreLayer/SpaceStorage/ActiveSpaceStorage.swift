import Foundation
import Combine

// Storage for store active space id for each screen.
protocol ActiveSpaceStorageProtocol: AnyObject {
    var activeSpaceId: String { get }
    var activeSpaceIdPublisher: AnyPublisher<String, Never> { get}
    func setActiveSpace(spaceId: String)
}

final class ActiveSpaceStorage: ActiveSpaceStorageProtocol {
    
    @Published
    private(set) var activeSpaceId: String = ""
    
    var activeSpaceIdPublisher: AnyPublisher<String, Never> {
        return $activeSpaceId.eraseToAnyPublisher()
    }
    
    func setActiveSpace(spaceId: String) {
        
    }
}
