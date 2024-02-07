import Foundation
import SwiftUI
import Services
import AnytypeCore

protocol SharingTipModuleAssemblyProtocol {
    @MainActor
    @available(iOS 17.0, *)
    func make() -> AnyView
}

final class SharingTipModuleAssembly: SharingTipModuleAssemblyProtocol {    
    // MARK: - SharingTipModuleAssemblyProtocol
    @MainActor
    @available(iOS 17.0, *)
    func make() -> AnyView {
        let viewModel = SharingTipViewModel()
        let view = SharingTipView(viewModel: viewModel)
        
        return view.eraseToAnyView()
    }
}
