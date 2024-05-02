import Foundation
import SwiftUI
import Services

@MainActor
protocol RelationsListCoordinatorAssemblyProtocol {
    func make(document: BaseDocumentProtocol, output: RelationValueCoordinatorOutput?) -> AnyView
}

@MainActor
final class RelationsListCoordinatorAssembly: RelationsListCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    
    nonisolated init(
        coordinatorsID: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - RelationsListCoordinatorAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, output: RelationValueCoordinatorOutput?) -> AnyView {
        RelationsListCoordinatorView(
            model: RelationsListCoordinatorViewModel(
                document: document,
                relationValueCoordinatorAssembly: self.coordinatorsID.relationValue(),
                relationValueProcessingService: self.serviceLocator.relationValueProcessingService(),
                output: output
            )
        ).eraseToAnyView()
    }
}

