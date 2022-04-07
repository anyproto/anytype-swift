import Foundation
import UIKit
import BlocksModels
import SwiftUI

final class AddNewRelationRouter {

    private let document: BaseDocumentProtocol
    private weak var viewController: UIViewController?
    
    init(document: BaseDocumentProtocol, viewController: UIViewController) {
        self.document = document
        self.viewController = viewController
    }
    
}
extension AddNewRelationRouter {
    
    func showAddNewRelationView(onSelect: ((_ newRelation: RelationMetadata) -> Void)?) {
        let relationService = RelationsService(objectId: document.objectId)

        let viewModel = SearchNewRelationViewModel(
            relationService: relationService,
            objectRelations: document.parsedRelations,
            onSelect: onSelect
        )

        let view = SearchNewRelationView(viewModel: viewModel)
        
        presentSwuftUIView(view: view, model: viewModel)
    }
    
    private func presentSwuftUIView<Content: View>(view: Content, model: Dismissible) {
        guard let viewController = viewController else { return }
        
        let controller = UIHostingController(rootView: view)
//        model.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        viewController.topPresentedController.present(controller, animated: true)
    }
    
}
