import Foundation
import SwiftUI
import Services
import AnytypeCore

protocol SharingTipModuleAssemblyProtocol {
    @MainActor
    func make(
        onClose: @escaping RoutingAction<Void>,
        onShareURL: @escaping RoutingAction<URL>
    ) -> AnyView?
}

final class SharingTipModuleAssembly: SharingTipModuleAssemblyProtocol {    
    // MARK: - SharingTipModuleAssemblyProtocol
    @MainActor
    func make(
        onClose: @escaping RoutingAction<Void>,
        onShareURL: @escaping RoutingAction<URL>
    ) -> AnyView? {
        if #available(iOS 17.0, *) {
            let viewModel = SharingTipViewModel()
            let view = SharingTipView(viewModel: viewModel)
            
            viewModel.onClose = onClose
            viewModel.onShareURL = onShareURL
            
            return view.eraseToAnyView()
        } else {
            return nil
        }
    }
}
