import SwiftUI

protocol KeyPhraseMoreInfoViewModuleAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class KeyPhraseMoreInfoViewModuleAssembly: KeyPhraseMoreInfoViewModuleAssemblyProtocol {
    
    // MARK: - KeyPhraseMoreInfoViewModuleAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return KeyPhraseMoreInfoView().eraseToAnyView()
    }
}
