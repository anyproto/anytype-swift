import Foundation
import Combine
import BlocksModels
import AnytypeCore

final class RelationsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    private enum Constants {
        static let installedSectionId = "InstalledId"
        static let marketplaceSectionId = "MarketplaceId"
    }
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var objects: [RelationDetails] = []
    private var marketplaceObjects: [RelationDetails] = []
    
    private let selectedRelations: ParsedRelations
    private let interactor: RelationsSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    private let onSelect: (_ relation: RelationDetails) -> Void
    
    init(
        selectedRelations: ParsedRelations,
        interactor: RelationsSearchInteractor,
        toastPresenter: ToastPresenterProtocol,
        onSelect: @escaping (_ relation: RelationDetails) -> Void
    ) {
        self.selectedRelations = selectedRelations
        self.interactor = interactor
        self.toastPresenter = toastPresenter
        self.onSelect = onSelect
    }
    
    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) {
        let objects = interactor.search(text: text, excludedIds: selectedRelations.installed.map(\.id))
        let sources = objects.map { $0.sourceObject }
        let marketplaceObjects = interactor.searchInMarketplace(text: text, excludedIds: sources)
        
        handleSearchResults(objects: objects, marketplaceObjects: marketplaceObjects)
        
        self.objects = objects
        self.marketplaceObjects = marketplaceObjects
    }
    
    func handleRowsSelection(ids: [String]) {
        
    }
    
    func createButtonModel(searchText: String) -> NewSearchViewModel.CreateButtonModel {
        return searchText.isEmpty ? .disabled : .enabled(title: Loc.createRelation(searchText))
    }
    
    func handleConfirmSelection(ids: [String]) {
        guard let id = ids.first else { return }
        
        if let marketplaceRelation = marketplaceObjects.first(where: { $0.id == id}) {
            guard let installedRelation = interactor.installRelation(objectId: marketplaceRelation.id) else {
                anytypeAssertionFailure("Relation not installed. Relation id \(marketplaceRelation.id)", domain: .relationSearch)
                return
            }
            toastPresenter.show(message: Loc.Relation.addedToLibrary(installedRelation.name))
            addRelation(relation: installedRelation)
            return
        }
        
        if let installedRelation = objects.first(where: { $0.id == id}) {
            addRelation(relation: installedRelation)
            return
        }
    
        anytypeAssertionFailure("Relation not found", domain: .relationSearch)
    }
    
    // MARK: - Private
    
    private func addRelation(relation: RelationDetails) {
        guard interactor.addRelationToObject(relation: relation) else {
            anytypeAssertionFailure("Relation not added to document. Relation id \(relation.id)", domain: .relationSearch)
            return
        }
        onSelect(relation)
    }
    
    private func handleSearchResults(objects: [RelationDetails], marketplaceObjects: [RelationDetails]) {
    
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: .builder {
                    if objects.isNotEmpty {
                        ListSectionConfiguration(
                            id: Constants.installedSectionId,
                            title: Loc.Relation.myRelations,
                            rows:  objects.asRowConfigurations()
                        )
                    }
                    if marketplaceObjects.isNotEmpty {
                        ListSectionConfiguration(
                            id: Constants.marketplaceSectionId,
                            title: Loc.marketplace,
                            rows:  marketplaceObjects.asRowConfigurations()
                        )
                    }
                })
            )
        )
    }
}

private extension Array where Element == RelationDetails {

    func asRowConfigurations() -> [ListRowConfiguration] {
        map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(relationDetails: details),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
    
}
