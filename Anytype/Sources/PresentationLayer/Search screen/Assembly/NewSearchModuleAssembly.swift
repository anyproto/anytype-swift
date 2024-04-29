import Foundation
import Services
import SwiftUI

final class NewSearchModuleAssembly: NewSearchModuleAssemblyProtocol {
 
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - NewSearchModuleAssemblyProtocol
    
    func relationsSearchModule(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        output: RelationSearchModuleOutput
    ) -> NewSearchView {
        
        let relationsInteractor = RelationsInteractor(objectId: document.objectId)
        let interactor = RelationsSearchInteractor(relationsInteractor: relationsInteractor)
        
        let internalViewModel = RelationsSearchViewModel(
            document: document,
            excludedRelationsIds: excludedRelationsIds,
            target: target,
            interactor: interactor,
            toastPresenter: uiHelpersDI.toastPresenter(),
            onSelect: { result in
                output.didAddRelation(result)
            }
        )
        let viewModel = NewSearchViewModel(
            searchPlaceholder: "Search or create a new relation",
            style: .default,
            itemCreationMode: .available(action: { title in
                output.didAskToShowCreateNewRelation(document: document, target: target, searchText: title)
            }),
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
}
