import Foundation
import Factory

extension Container {
    var shareOptionsInteractor: Factory<ShareOptionsInteractorProtocol> {
        self { ShareOptionsInteractor() }
    }
}
