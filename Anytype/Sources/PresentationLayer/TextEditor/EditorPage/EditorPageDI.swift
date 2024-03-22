import Foundation

extension Container {
    var objectHeaderInteractor: Factory<ObjectHeaderInteractorProtocol> {
        self { ObjectHeaderInteractor() }
    }
}
