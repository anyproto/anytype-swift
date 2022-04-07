import Foundation
import UIKit
import BlocksModels
import SwiftUI

final class AddNewRelationRouter {

    var onSelect: ((_ newRelation: RelationMetadata) -> Void)?
    
    private let document: BaseDocumentProtocol
    private weak var viewController: UIViewController?
    
    init(
        document: BaseDocumentProtocol,
        viewController: UIViewController
    ) {
        self.document = document
        self.viewController = viewController
    }
    
}

extension AddNewRelationRouter {
    
    func showAddNewRelationView() {
        let relationService = RelationsService(objectId: document.objectId)

        let viewModel = SearchNewRelationViewModel(
            objectRelations: document.parsedRelations,
            relationService: relationService,
            output: self,
            onSelect: nil
        )

        let view = SearchNewRelationView(viewModel: viewModel)
        
        presentSwuftUIView(view: view)
    }
    
}

extension AddNewRelationRouter: SearchNewRelationModuleOutput {
    
    func didAddRelation(_ relation: RelationMetadata) {
        onSelect?(relation)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
    func didAskToShowCreateNewRelation(searchText: String) {
        viewController?.topPresentedController.dismiss(animated: true) { [weak self] in
            self?.showCreateNewRelationView(searchText: searchText)
        }
    }
    
    private func showCreateNewRelationView(searchText: String) {
        let viewModel = NewRelationViewModel(name: searchText)
        let view = NewRelationView(viewModel: viewModel)
        
        let popup = AnytypePopup(contentView: view)
        viewController?.topPresentedController.present(popup, animated: true)
    }
      
}

private extension AddNewRelationRouter {
    
    func presentSwuftUIView<Content: View>(view: Content) {
        guard let viewController = viewController else { return }
        
        let controller = UIHostingController(rootView: view)
        viewController.topPresentedController.present(controller, animated: true)
    }
    
}
