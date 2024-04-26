import Foundation
import UIKit
import SwiftUI
import Services

protocol NewRelationModuleAssemblyProtocol {
    @MainActor
    func make(
        document: BaseDocumentProtocol,
        target: RelationsModuleTarget,
        searchText: String,
        output: NewRelationModuleOutput
    ) -> UIKitModule<NewRelationModuleInput>
}

final class NewRelationModuleAssembly: NewRelationModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - NewRelationModuleAssemblyProtocol
    
    @MainActor
    func make(
        document: BaseDocumentProtocol,
        target: RelationsModuleTarget,
        searchText: String,
        output: NewRelationModuleOutput
    ) -> UIKitModule<NewRelationModuleInput> {
        
        let relationsInteractor = RelationsInteractor(
            relationsService: serviceLocator.relationService(objectId: document.objectId),
            dataviewService:  serviceLocator.dataviewService()
        )
        let viewModel = NewRelationViewModel(
            name: searchText,
            document: document, 
            target: target,
            service: RelationsService(objectId: document.objectId),
            toastPresenter: uiHelpersDI.toastPresenter(),
            objectTypeProvider: serviceLocator.objectTypeProvider(), 
            relationsInteractor: relationsInteractor,
            output: output
        )
        let view = NewRelationView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: view)
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
        }
        
        return UIKitModule(viewController: vc, input: viewModel)
    }
    
}
