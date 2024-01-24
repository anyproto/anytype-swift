import Foundation
import SwiftUI

@MainActor
final class SelectRelationListCoordinatorViewModel: ObservableObject, SelectRelationListModuleOutput {

    private let objectId: String
    private let configuration: RelationModuleConfiguration
    private let selectedOption: SelectRelationOption?
    private let selectRelationListModuleAssemblyProtocol: SelectRelationListModuleAssemblyProtocol

    @Published var dismiss = false
    
    init(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOption: SelectRelationOption?,
        selectRelationListModuleAssemblyProtocol: SelectRelationListModuleAssemblyProtocol
    ) {
        self.objectId = objectId
        self.configuration = configuration
        self.selectedOption = selectedOption
        self.selectRelationListModuleAssemblyProtocol = selectRelationListModuleAssemblyProtocol
    }
    
    func selectRelationListModule() -> AnyView {
        selectRelationListModuleAssemblyProtocol.make(
            objectId: objectId,
            configuration: configuration,
            selectedOption: selectedOption,
            output: self
        )
    }

    // MARK: - SelectRelationListModuleOutput
    
    func onOptionSelected() {
        dismiss.toggle()
    }
}
