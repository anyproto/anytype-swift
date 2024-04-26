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
    
    private var onCompletion: ((_ newRelationDetails: RelationDetails, _ isNew: Bool) -> Void)?
    private var document: BaseDocumentProtocol?
    private weak var newRelationModuleInput: NewRelationModuleInput?
    
    init(
        navigationContext: NavigationContextProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.newSearchModuleAssembly = newSearchModuleAssembly
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
        let view = NewRelationCoordinatorView(name: searchText, document: document, target: target, output: self)
                
        let vc = UIHostingController(rootView: view)
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
        }
        
        navigationContext.present(vc, animated: true)
    }
}

// MARK: - NewRelationCoordinatorViewOutput

extension AddNewRelationCoordinator: NewRelationCoordinatorViewOutput {
    func didCreateRelation(_ relation: RelationDetails) {
        onCompletion?(relation, true)
    }
}
