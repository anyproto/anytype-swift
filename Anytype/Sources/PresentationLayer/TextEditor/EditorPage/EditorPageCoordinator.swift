import Foundation
import UIKit
import Services

protocol EditorPageCoordinatorProtocol: AnyObject {
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool)
}

final class EditorPageCoordinator: EditorPageCoordinatorProtocol, WidgetObjectListCommonModuleOutput {
    
    private weak var browserController: EditorBrowserController?
    private let editorAssembly: EditorAssembly
    private let alertHelper: AlertHelper
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        browserController: EditorBrowserController?,
        editorAssembly: EditorAssembly,
        alertHelper: AlertHelper,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.browserController = browserController
        self.editorAssembly = editorAssembly
        self.alertHelper = alertHelper
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - EditorPageCoordinatorProtocol
    
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool) {
        if !data.isSupportedForEdit {
            showUnsupportedTypeAlert(documentId: data.objectId)
            return
        }
        
        let controller = editorAssembly.buildEditorController(
            browser: browserController,
            data: data,
            widgetListOutput: self
        )
        
        if replaceCurrentPage {
            browserController?.childNavigation?.replaceLastViewController(controller, animated: false)
        } else {
            browserController?.childNavigation?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - WidgetObjectListCommonModuleOutput
    
    func onObjectSelected(screenData: EditorScreenData) {
        startFlow(data: screenData, replaceCurrentPage: false)
    }
    
    // MARK: - Private
    
    private func showUnsupportedTypeAlert(documentId: String) {
        Task { @MainActor in
            let document = BaseDocument(objectId: documentId)
            try await document.openForPreview()

            guard let typeId = document.details?.type else { return }
            
            let typeName = objectTypeProvider.objectType(id: typeId)?.name ?? Loc.unknown
            
            alertHelper.showToast(
                title: "Not supported type \"\(typeName)\"",
                message: "You can open it via desktop"
            )
        }
    }
}
