import Foundation
import UIKit
import Services
import SwiftUI

@MainActor
protocol AddNewRelationCoordinatorProtocol {
    func showAddNewRelationView(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    )
    
    func addNewRelationView(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    ) -> NewSearchView
}

@MainActor
final class AddNewRelationCoordinator {
    private let navigationContext: NavigationContextProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let newRelationModuleAssembly: NewRelationModuleAssemblyProtocol
    
    private var onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    private var document: BaseDocumentProtocol?
    private weak var newRelationModuleInput: NewRelationModuleInput?
    
    init(
        navigationContext: NavigationContextProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        newRelationModuleAssembly: NewRelationModuleAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.newRelationModuleAssembly = newRelationModuleAssembly
    }
    
}

// MARK: - Entry point

extension AddNewRelationCoordinator: AddNewRelationCoordinatorProtocol {
    
    func showAddNewRelationView(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    ) {
        self.document = document
        self.onCompletion = onCompletion

        let view = newSearchModuleAssembly.relationsSearchModule(
            document: document,
            excludedRelationsIds: excludedRelationsIds,
            target: target,
            output: self
        )
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    func addNewRelationView(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    ) -> NewSearchView {
        self.document = document
        self.onCompletion = onCompletion
        return newSearchModuleAssembly.relationsSearchModule(
            document: document,
            excludedRelationsIds: excludedRelationsIds,
            target: target,
            output: self
        )
    }
}

// MARK: - SearchNewRelationModuleOutput

extension AddNewRelationCoordinator: RelationSearchModuleOutput {
    
    func didAddRelation(_ relationDetails: RelationDetails) {
        onCompletion?(relationDetails, false)
        navigationContext.dismissTopPresented(animated: true)
    }
    
    func didAskToShowCreateNewRelation(document: BaseDocumentProtocol, target: RelationsModuleTarget, searchText: String) {
        navigationContext.dismissTopPresented(animated: true)
        showCreateNewRelationView(document: document, target: target, searchText: searchText)
    }
    
    private func showCreateNewRelationView(document: BaseDocumentProtocol, target: RelationsModuleTarget, searchText: String) {
        let module = newRelationModuleAssembly.make(
            document: document,
            target: target,
            searchText: searchText,
            output: self
        )
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
        guard let document else { return }
        let view = newSearchModuleAssembly.multiselectObjectTypesSearchModule(
            selectedObjectTypeIds: selectedObjectTypesIds,
            spaceId: document.spaceId
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
