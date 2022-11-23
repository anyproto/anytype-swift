import Foundation

protocol AddNewRelationCoordinatorAssemblyProtocol {
    func make(document: BaseDocumentProtocol) -> AddNewRelationCoordinatorProtocol
}

final class AddNewRelationCoordinatorAssembly: AddNewRelationCoordinatorAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    func make(document: BaseDocumentProtocol) -> AddNewRelationCoordinatorProtocol {
        return AddNewRelationCoordinator(
            document: document,
            navigationContext: NavigationContext(rootViewController: uiHelpersDI.viewControllerProvider.rootViewController)
        )
    }
}
