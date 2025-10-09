import Foundation
import SwiftUI

@MainActor
final class ExperimentalFeaturesViewModel: ObservableObject {
    
    @Injected(\.experimentalFeaturesStorage)
    private var experimentalFeaturesStorage: any ExperimentalFeaturesStorageProtocol
    
    @Published var newObjectCreationMenu: Bool = false
    
    init() {
        newObjectCreationMenu = experimentalFeaturesStorage.newObjectCreationMenu
    }
    
    func onUpdateNewObjectCreationMenu() {
        experimentalFeaturesStorage.newObjectCreationMenu = newObjectCreationMenu
    }
}
