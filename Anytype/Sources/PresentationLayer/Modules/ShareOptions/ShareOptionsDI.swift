import Foundation
import Factory

extension Container {
    var shareOptionsInteractor: Factory<any ShareOptionsInteractorProtocol> {
        self { ShareOptionsInteractor() }
    }
}
