import Foundation
import UIKit
import SwiftUI
import Services

protocol NewRelationModuleAssemblyProtocol {
    func make(
        document: BaseDocumentProtocol,
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
    
    func make(
        document: BaseDocumentProtocol,
        searchText: String,
        output: NewRelationModuleOutput
    ) -> UIKitModule<NewRelationModuleInput> {
        let viewModel = NewRelationViewModel(
            name: searchText,
            document: document,
            service: RelationsService(objectId: document.objectId),
            toastPresenter: uiHelpersDI.toastPresenter(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            output: output
        )
        let view = NewRelationView(viewModel: viewModel)
        
        let vc = UIHostingController(rootView: view)
        
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.selectedDetentIdentifier = .medium
            }
        }
        
        return UIKitModule(viewController: vc, input: viewModel)
    }
    
}
