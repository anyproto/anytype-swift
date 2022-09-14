import Foundation
import UIKit
import BlocksModels
import SwiftUI

final class AddNewRelationCoordinator {
    
    private let document: BaseDocumentProtocol
    private weak var viewController: UIViewController?
    
    private var onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    
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

extension AddNewRelationCoordinator {
    
    func showAddNewRelationView(onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?) {
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

extension AddNewRelationCoordinator: SearchNewRelationModuleOutput {
    
    func didAddRelation(_ relationDetails: RelationDetails) {
        onCompletion?(relationDetails, false)
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
        
        let vc = UIHostingController(rootView: view)
        
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.selectedDetentIdentifier = .medium
            }
        }
        
        viewController?.topPresentedController.present(vc, animated: true)
    }
      
}

// MARK: - NewRelationModuleOutput

extension AddNewRelationCoordinator: NewRelationModuleOutput {
    
    func didAskToShowRelationFormats(selectedFormat: SupportedRelationFormat) {
        let viewModel = RelationFormatsListViewModel(selectedFormat: selectedFormat, output: self)
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
    
    func didCreateRelation(_ relation: RelationDetails) {
        onCompletion?(relation, true)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
    private func handleObjectTypesSelection(objectTypesIds: [String]) {
        newRelationModuleInput?.updateTypesRestriction(objectTypeIds: objectTypesIds)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
}

// MARK: - RelationFormatsListModuleOutput

extension AddNewRelationCoordinator: RelationFormatsListModuleOutput {
    
    func didSelectFormat(_ format: SupportedRelationFormat) {
        newRelationModuleInput?.updateRelationFormat(format)
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
}

// MARK: - Private extension

private extension AddNewRelationCoordinator {
    
    func presentSwiftUIView<Content: View>(view: Content) {
        guard let viewController = viewController else { return }
        
        let controller = UIHostingController(rootView: view)
        viewController.topPresentedController.present(controller, animated: true)
    }
    
}
