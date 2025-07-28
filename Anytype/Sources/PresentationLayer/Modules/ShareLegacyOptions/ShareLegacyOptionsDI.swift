import Foundation
import Factory

extension Container {
    var shareLegacyOptionsInteractor: Factory<any ShareLegacyOptionsInteractorProtocol> {
        self { ShareLegacyOptionsInteractor() }
    }
}
