import Foundation
import UIKit
import BlocksModels
import SwiftUI

protocol AddNewRelationCoordinatorProtocol {
    func showAddNewRelationView(onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?)
}

final class AddNewRelationCoordinator {
    
    private let document: BaseDocumentProtocol
    private let navigationContext: NavigationContextProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let newRelationModuleAssembly: NewRelationModuleAssemblyProtocol
    
    private var onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    
    private weak var newRelationModuleInput: NewRelationModuleInput?
    
    init(
        document: BaseDocumentProtocol,
        navigationContext: NavigationContextProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        newRelationModuleAssembly: NewRelationModuleAssemblyProtocol
    ) {
        self.document = document
        self.navigationContext = navigationContext
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.newRelationModuleAssembly = newRelationModuleAssembly
    }
    
}

// MARK: - Entry point

extension AddNewRelationCoordinator: AddNewRelationCoordinatorProtocol {
    
    func showAddNewRelationView(onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?) {
        self.onCompletion = onCompletion

        let view = newSearchModuleAssembly.relationsSearchModule(
            document: document,
            output: self
        )
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
}

// MARK: - SearchNewRelationModuleOutput

extension AddNewRelationCoordinator: RelationSearchModuleOutput {
    
    func didAddRelation(_ relationDetails: RelationDetails) {
        onCompletion?(relationDetails, false)
        navigationContext.dismissTopPresented(animated: true)
    }
    
    func didAskToShowCreateNewRelation(searchText: String) {
        navigationContext.dismissTopPresented(animated: true)
        showCreateNewRelationView(searchText: searchText)
    }
    
    private func showCreateNewRelationView(searchText: String) {
        let module = newRelationModuleAssembly.make(document: document, searchText: searchText, output: self)
        newRelationModuleInput = module.input
        
        navigationContext.present(module.viewController, animated: true)
    }
      
}

// MARK: - NewRelationModuleOutput

extension AddNewRelationCoordinator: NewRelationModuleOutput {
    
    func didAskToShowRelationFormats(selectedFormat: SupportedRelationFormat) {
        let viewModel = RelationFormatsListViewModel(selectedFormat: selectedFormat, output: self)
        let view = RelationFormatsListView(viewModel: viewModel)
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String]) {
        let view = newSearchModuleAssembly.multiselectObjectTypesSearchModule(
            selectedObjectTypeIds: selectedObjectTypesIds
        ) { [weak self] ids in
            self?.handleObjectTypesSelection(objectTypesIds: ids)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    func didCreateRelation(_ relation: RelationDetails) {
        onCompletion?(relation, true)
        navigationContext.dismissTopPresented(animated: true)
    }
    
    private func handleObjectTypesSelection(objectTypesIds: [String]) {
        newRelationModuleInput?.updateTypesRestriction(objectTypeIds: objectTypesIds)
        navigationContext.dismissTopPresented(animated: true)
    }
    
}

// MARK: - RelationFormatsListModuleOutput

extension AddNewRelationCoordinator: RelationFormatsListModuleOutput {
    
    func didSelectFormat(_ format: SupportedRelationFormat) {
        newRelationModuleInput?.updateRelationFormat(format)
        navigationContext.dismissTopPresented(animated: true)
    }
    
}
