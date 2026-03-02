import Foundation
import SwiftUI

@MainActor
@Observable
final class ExperimentalFeaturesViewModel {

    @ObservationIgnored
    @Injected(\.experimentalFeaturesStorage)
    private var experimentalFeaturesStorage: any ExperimentalFeaturesStorageProtocol

    var newObjectCreationMenu: Bool = false
    var hideReadPreviews: Bool = false

    init() {
        newObjectCreationMenu = experimentalFeaturesStorage.newObjectCreationMenu
        hideReadPreviews = experimentalFeaturesStorage.hideReadPreviews
    }

    func onUpdateNewObjectCreationMenu() {
        experimentalFeaturesStorage.newObjectCreationMenu = newObjectCreationMenu
    }

    func onUpdateHideReadPreviews() {
        experimentalFeaturesStorage.hideReadPreviews = hideReadPreviews
    }
}
