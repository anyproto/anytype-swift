import Foundation
import UIKit
import BlocksModels
import SwiftUI

final class AddNewRelationRouter {
    
    private let document: BaseDocumentProtocol
    private weak var viewController: UIViewController?
    
    private var onCompletion: ((_ newRelation: RelationMetadata) -> Void)?
    
    private weak var newRelationModuleInput: NewRelationModuleInput?
    
    init(
        document: BaseDocumentProtocol,
        viewController: UIViewController
    ) {
        self.document = document
        self.viewController = viewController
    }
    
}

// MARK: - Entry point

extension AddNewRelationRouter {
    
    func showAddNewRelationView(onCompletion: ((_ newRelation: RelationMetadata) -> Void)?) {
        self.onCompletion = onCompletion
        
        let relationService = RelationsService(objectId: document.objectId)

        let viewModel = SearchNewRelationViewModel(
            objectRelations: document.parsedRelations,
            relationService: relationService,
            output: self
        )

        let view = SearchNewRelationView(viewModel: viewModel)
        
        presentSwiftUIView(view: view)
    }
    
}

// MARK: - SearchNewRelationModuleOutput

extension AddNewRelationRouter: SearchNewRelationModuleOutput {
    
    func didAddRelation(_ relation: RelationMetadata) {
        onCompletion?(relation)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
    func didAskToShowCreateNewRelation(searchText: String) {
        viewController?.topPresentedController.dismiss(animated: true) { [weak self] in
            self?.showCreateNewRelationView(searchText: searchText)
        }
    }
    
    private func showCreateNewRelationView(searchText: String) {
        let viewModel = NewRelationViewModel(
            name: searchText,
            service: RelationsService(objectId: document.objectId),
            output: self
        )
        let view = NewRelationView(viewModel: viewModel)
        
        newRelationModuleInput = viewModel
        
        let popup = AnytypePopup(contentView: view)
        viewController?.topPresentedController.present(popup, animated: true)
    }
      
}

// MARK: - NewRelationModuleOutput

extension AddNewRelationRouter: NewRelationModuleOutput {
    
    func didAskToShowRelationFormats() {
        let viewModel = RelationFormatsListViewModel(output: self)
        let view = RelationFormatsListView(viewModel: viewModel)
        
        presentSwiftUIView(view: view)
    }
    
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String]) {
        let view = NewSearchModuleAssembly.multiselectObjectTypesSearchModule(
            selectedObjectTypeIds: selectedObjectTypesIds
        ) { [weak self] ids in
            self?.handleObjectTypesSelection(objectTypesIds: ids)
        }
        
        presentSwiftUIView(view: view)
    }
    
    func didCreateRelation(_ relationMetadata: RelationMetadata) {
        onCompletion?(relationMetadata)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
    private func handleObjectTypesSelection(objectTypesIds: [String]) {
        newRelationModuleInput?.updateTypesRestriction(objectTypeIds: objectTypesIds)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
}

// MARK: - RelationFormatsListModuleOutput

extension AddNewRelationRouter: RelationFormatsListModuleOutput {
    
    func didSelectFormat(_ format: SupportedRelationFormat) {
        newRelationModuleInput?.updateRelationFormat(format)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
}

// MARK: - Private extension

private extension AddNewRelationRouter {
    
    func presentSwiftUIView<Content: View>(view: Content) {
        guard let viewController = viewController else { return }
        
        let controller = UIHostingController(rootView: view)
        viewController.topPresentedController.present(controller, animated: true)
    }
    
}
