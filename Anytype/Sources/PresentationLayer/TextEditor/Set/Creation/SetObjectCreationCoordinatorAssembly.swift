import Foundation
import UIKit
import SwiftUI

protocol SetObjectCreationCoordinatorAssemblyProtocol {
    func make(
        setDocument: SetDocumentProtocol,
        browser: EditorBrowserController?
    ) -> SetObjectCreationCoordinatorProtocol
}

final class SetObjectCreationCoordinatorAssembly: SetObjectCreationCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        serviceLocator: ServiceLocator,
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetObjectCreationCoordinatorAssemblyProtocol
    
    func make(
        setDocument: SetDocumentProtocol,
        browser: EditorBrowserController?
    ) -> SetObjectCreationCoordinatorProtocol {
        SetObjectCreationCoordinator(
            setDocument: setDocument,
            navigationContext: uiHelpersDI.commonNavigationContext(),
            editorPageCoordinator: coordinatorsDI.editorPage().make(browserController: browser),
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            objectCreationHelper: serviceLocator.setObjectCreationHelper(objectId: setDocument.objectId, blockId: nil),
            createObjectModuleAssembly: modulesDI.createObject()
        )
    }
}
