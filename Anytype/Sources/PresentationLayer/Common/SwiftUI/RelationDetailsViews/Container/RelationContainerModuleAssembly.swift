import Foundation
import SwiftUI

protocol RelationContainerModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        title: String,
        output: RelationContainerModuleOutput?
    ) -> AnyView
}

final class RelationContainerModuleAssembly: RelationContainerModuleAssemblyProtocol {
    
    // MARK: - RelationContainerModuleAssemblyProtocol
    
    @MainActor
    func make(
        title: String,
        output: RelationContainerModuleOutput?
    )  -> AnyView {
        RelationContainerView(
            viewModel: RelationContainerViewModel(
                title: title,
                output: output
            )
        )
        .eraseToAnyView()
    }
}
