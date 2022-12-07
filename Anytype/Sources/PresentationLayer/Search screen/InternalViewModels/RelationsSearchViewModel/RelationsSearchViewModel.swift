import Foundation
import Combine
import BlocksModels

final class RelationsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private let selectedRelations: ParsedRelations
    private let interactor: RelationsSearchInteractor
    private weak var output: SearchNewRelationModuleOutput?
    
    init(
        selectedRelations: ParsedRelations,
        interactor: RelationsSearchInteractor,
        output: SearchNewRelationModuleOutput
    ) {
        self.selectedRelations = selectedRelations
        self.interactor = interactor
        self.output = output
    }
    
    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) {
        let objects = interactor.search(text: text, excludedIds: selectedRelations.all.map(\.id))
        let sources = objects.map { $0.sourceObject }
        let marketplaceObjects = interactor.searchInMarketplace(text: text, excludedIds: sources)
        
        if objects.isEmpty && marketplaceObjects.isEmpty {
            handleError(for: text)
        } else {
            handleSearchResults(objects: objects, marketplaceObjects: marketplaceObjects)
        }
    }
    
    func handleRowsSelection(ids: [String]) {
        
    }
    
    func createButtonModel(searchText: String) -> NewSearchCreateButtonModel {
        return NewSearchCreateButtonModel(show: searchText.isNotEmpty, title: Loc.createRelation(searchText))
    }
    
    func handleConfirmSelection(ids: [String]) {
        
    }
    
    // MARK: - Private
    
    private func handleError(for text: String) {
        viewStateSubject.send(.error(.noObjectError(searchText: text)))
    }
    
    private func handleSearchResults(objects: [RelationDetails], marketplaceObjects: [RelationDetails]) {
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: [
                    ListSectionConfiguration(
                        id: "MyId",
                        title: "My relations",
                        rows:  objects.asRowConfigurations()
                    ),
                    ListSectionConfiguration(
                        id: "MarketplaceId",
                        title: "Marketplace",
                        rows:  marketplaceObjects.asRowConfigurations()
                    )
                ])
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
