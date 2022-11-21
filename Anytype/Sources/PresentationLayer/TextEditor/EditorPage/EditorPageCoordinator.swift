import Foundation
import UIKit
import BlocksModels

protocol EditorPageCoordinatorProtocol: AnyObject {
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool)
}

final class EditorPageCoordinator: EditorPageCoordinatorProtocol {
    
    private weak var rootController: EditorBrowserController?
    private weak var viewController: UIViewController?
    private let editorAssembly: EditorAssembly
    private let alertHelper: AlertHelper
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController?,
        editorAssembly: EditorAssembly,
        alertHelper: AlertHelper
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.editorAssembly = editorAssembly
        self.alertHelper = alertHelper
    }
    
    // MARK: - EditorPageCoordinatorProtocol
    
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool) {
        if let details = ObjectDetailsStorage.shared.get(id: data.pageId),
            !ObjectTypeProvider.shared.isSupported(typeId: details.type) {
            showUnsupportedTypeAlert(typeId: details.type)
            return
        }
        
        let controller = editorAssembly.buildEditorController(
            browser: rootController,
            data: data
        )
        
        if replaceCurrentPage {
            rootController?.childNavigation?.replaceLastViewController(controller, animated: false)
        } else {
            viewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Private
    
    private func showUnsupportedTypeAlert(typeId: String) {
        let typeName = ObjectTypeProvider.shared.objectType(id: typeId)?.name ?? Loc.unknown
        
        alertHelper.showToast(
            title: "Not supported type \"\(typeName)\"",
            message: "You can open it via desktop"
        )
    }
}
