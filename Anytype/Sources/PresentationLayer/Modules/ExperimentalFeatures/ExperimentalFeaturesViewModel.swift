import Foundation
import SwiftUI

@MainActor
@Observable
final class ExperimentalFeaturesViewModel {

    @ObservationIgnored
    @Injected(\.experimentalFeaturesStorage)
    private var experimentalFeaturesStorage: any ExperimentalFeaturesStorageProtocol

    var newObjectCreationMenu: Bool = false
    
    init() {
        newObjectCreationMenu = experimentalFeaturesStorage.newObjectCreationMenu
    }
    
    func onUpdateNewObjectCreationMenu() {
        experimentalFeaturesStorage.newObjectCreationMenu = newObjectCreationMenu
    }
}
