import Foundation
import UIKit
import BlocksModels

protocol EditorPageCoordinatorProtocol: AnyObject {
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool)
}

final class EditorPageCoordinator: EditorPageCoordinatorProtocol {
    
    private weak var browserController: EditorBrowserController?
    private let editorAssembly: EditorAssembly
    private let alertHelper: AlertHelper
    
    init(
        browserController: EditorBrowserController?,
        editorAssembly: EditorAssembly,
        alertHelper: AlertHelper
    ) {
        self.browserController = browserController
        self.editorAssembly = editorAssembly
        self.alertHelper = alertHelper
    }
    
    // MARK: - EditorPageCoordinatorProtocol
    
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool) {
        if let details = ObjectDetailsStorage.shared.get(id: data.pageId),
            !ObjectTypeProvider.shared.isSupportedForEdit(typeId: details.type) {
            showUnsupportedTypeAlert(typeId: details.type)
            return
        }
        
        let controller = editorAssembly.buildEditorController(
            browser: browserController,
            data: data
        )
        
        if replaceCurrentPage {
            browserController?.childNavigation?.replaceLastViewController(controller, animated: false)
        } else {
            browserController?.childNavigation?.pushViewController(controller, animated: true)
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
